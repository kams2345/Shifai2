// Supabase Edge Function: cleanup-expired-exports
// Cron job: deletes medical export PDFs older than 7 days
// Schedule: daily at 03:00 UTC

import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const EXPORT_BUCKET = "medical-exports";
const MAX_AGE_DAYS = 7;

serve(async (req: Request) => {
    try {
        // This function should only be called by Supabase cron
        const authHeader = req.headers.get("Authorization");
        const supabase = createClient(
            Deno.env.get("SUPABASE_URL") ?? "",
            Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? ""
        );

        // List all files in the exports bucket
        const { data: folders, error: listError } = await supabase.storage
            .from(EXPORT_BUCKET)
            .list("", { limit: 1000 });

        if (listError) {
            console.error("Failed to list folders:", listError);
            return new Response(JSON.stringify({ error: listError.message }), { status: 500 });
        }

        let deletedCount = 0;
        const cutoffDate = new Date(Date.now() - MAX_AGE_DAYS * 24 * 60 * 60 * 1000);

        for (const folder of folders ?? []) {
            // List files in each user's folder
            const { data: files } = await supabase.storage
                .from(EXPORT_BUCKET)
                .list(folder.name);

            for (const file of files ?? []) {
                const createdAt = new Date(file.created_at);
                if (createdAt < cutoffDate) {
                    const filePath = `${folder.name}/${file.name}`;
                    const { error: deleteError } = await supabase.storage
                        .from(EXPORT_BUCKET)
                        .remove([filePath]);

                    if (!deleteError) {
                        deletedCount++;
                        console.log(`Deleted expired export: ${filePath}`);
                    }
                }
            }
        }

        return new Response(
            JSON.stringify({
                success: true,
                deleted_count: deletedCount,
                cutoff_date: cutoffDate.toISOString(),
            }),
            { status: 200, headers: { "Content-Type": "application/json" } }
        );

    } catch (error) {
        console.error("Cleanup error:", error);
        return new Response(
            JSON.stringify({ error: error.message }),
            { status: 500, headers: { "Content-Type": "application/json" } }
        );
    }
});
