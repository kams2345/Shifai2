import { serve } from "https://deno.land/std@0.208.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.39.3";

/**
 * cleanup-expired — cron-triggered maintenance function.
 * 1. Delete expired share links (past expires_at)
 * 2. Remove orphaned storage blobs
 * 3. Report freed resources
 *
 * Triggered by: pg_cron or Supabase scheduled function
 * Auth: service_role only
 */
serve(async (req: Request) => {
    try {
        // Verify service role
        const authHeader = req.headers.get("Authorization");
        const serviceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;

        if (!authHeader?.includes(serviceKey)) {
            return new Response(
                JSON.stringify({ error: "Service role required" }),
                { status: 403, headers: { "Content-Type": "application/json" } }
            );
        }

        const supabase = createClient(
            Deno.env.get("SUPABASE_URL")!,
            serviceKey,
            { auth: { persistSession: false } }
        );

        // 1. Delete expired share links
        const now = new Date().toISOString();
        const { data: expiredLinks, error: linksError } = await supabase
            .from("share_links")
            .delete()
            .lt("expires_at", now)
            .select("id, storage_path");

        if (linksError) throw linksError;

        // 2. Remove orphaned storage blobs for expired links
        let freedBytes = 0;
        const orphanedPaths: string[] = [];

        for (const link of expiredLinks || []) {
            if (link.storage_path) {
                const { error: storageError } = await supabase.storage
                    .from("shared-exports")
                    .remove([link.storage_path]);

                if (!storageError) {
                    orphanedPaths.push(link.storage_path);
                    freedBytes += 81920; // Estimate ~80KB per export
                }
            }
        }

        // 3. Clean up old sync conflict records (> 30 days)
        const thirtyDaysAgo = new Date(Date.now() - 30 * 24 * 60 * 60 * 1000).toISOString();
        await supabase
            .from("sync_conflicts")
            .delete()
            .lt("created_at", thirtyDaysAgo);

        const result = {
            expiredLinks: expiredLinks?.length ?? 0,
            orphanedBlobs: orphanedPaths.length,
            freedBytes,
            cleanedAt: now,
        };

        console.log(`[cleanup-expired] ${JSON.stringify(result)}`);

        return new Response(JSON.stringify(result), {
            status: 200,
            headers: { "Content-Type": "application/json" },
        });

    } catch (error) {
        console.error("[cleanup-expired] Error:", error);
        return new Response(
            JSON.stringify({ error: "Cleanup failed", details: String(error) }),
            { status: 500, headers: { "Content-Type": "application/json" } }
        );
    }
});
