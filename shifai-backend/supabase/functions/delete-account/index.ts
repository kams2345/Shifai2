// Supabase Edge Function: delete-account (S9-4)
// GDPR Art. 17 — Right to Erasure
// Deletes all user data: encrypted blobs, sync metadata, exports, analytics, auth

import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const corsHeaders = {
    "Access-Control-Allow-Origin": "*",
    "Access-Control-Allow-Headers":
        "authorization, x-client-info, apikey, content-type",
};

serve(async (req: Request) => {
    if (req.method === "OPTIONS") {
        return new Response("ok", { headers: corsHeaders });
    }

    if (req.method !== "POST") {
        return new Response(
            JSON.stringify({ error: "Method not allowed" }),
            { status: 405, headers: { ...corsHeaders, "Content-Type": "application/json" } }
        );
    }

    try {
        const authHeader = req.headers.get("Authorization");
        if (!authHeader) {
            return new Response(
                JSON.stringify({ error: "Unauthorized" }),
                { status: 401, headers: { ...corsHeaders, "Content-Type": "application/json" } }
            );
        }

        // User-scoped client for auth
        const userClient = createClient(
            Deno.env.get("SUPABASE_URL") ?? "",
            Deno.env.get("SUPABASE_ANON_KEY") ?? "",
            { global: { headers: { Authorization: authHeader } } }
        );

        const { data: { user } } = await userClient.auth.getUser();
        if (!user) {
            return new Response(
                JSON.stringify({ error: "Unauthorized" }),
                { status: 401, headers: { ...corsHeaders, "Content-Type": "application/json" } }
            );
        }

        // Double-confirm: require explicit confirmation in body
        const body = await req.json();
        if (body.confirm !== "DELETE_ALL_MY_DATA") {
            return new Response(
                JSON.stringify({ error: "Missing confirmation. Send { confirm: 'DELETE_ALL_MY_DATA' }" }),
                { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } }
            );
        }

        // Service role client for admin operations
        const adminClient = createClient(
            Deno.env.get("SUPABASE_URL") ?? "",
            Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? ""
        );

        const userId = user.id;

        // 1. Delete encrypted data
        await adminClient.from("encrypted_user_data").delete().eq("user_id", userId);

        // 2. Delete sync metadata
        await adminClient.from("sync_metadata").delete().eq("user_id", userId);

        // 3. Delete medical exports (storage + DB)
        const { data: exports } = await adminClient
            .from("medical_exports")
            .select("file_path")
            .eq("user_id", userId);

        if (exports && exports.length > 0) {
            const paths = exports.map((e: { file_path: string }) => e.file_path);
            await adminClient.storage.from("medical-exports").remove(paths);
            await adminClient.from("medical_exports").delete().eq("user_id", userId);
        }

        // 4. Delete analytics events
        await adminClient.from("analytics_events").delete().eq("user_id", userId);

        // 5. Log deletion (GDPR Art. 17 compliance)
        await adminClient.from("deletion_log").insert({
            user_id: userId,
            deletion_type: "user_request",
            completed_at: new Date().toISOString(),
        });

        // 6. Delete auth user (this is irreversible)
        const { error: deleteError } = await adminClient.auth.admin.deleteUser(userId);
        if (deleteError) {
            return new Response(
                JSON.stringify({ error: `Auth deletion failed: ${deleteError.message}` }),
                { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } }
            );
        }

        return new Response(
            JSON.stringify({
                success: true,
                message: "Toutes tes données ont été supprimées. Compte supprimé.",
                deleted: {
                    encrypted_data: true,
                    sync_metadata: true,
                    medical_exports: exports?.length ?? 0,
                    analytics_events: true,
                    auth_user: true,
                },
            }),
            { status: 200, headers: { ...corsHeaders, "Content-Type": "application/json" } }
        );
    } catch (error) {
        return new Response(
            JSON.stringify({ error: (error as Error).message }),
            { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } }
        );
    }
});
