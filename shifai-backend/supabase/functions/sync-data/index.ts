// Supabase Edge Function: sync-data
// Handles encrypted blob push/pull for zero-knowledge sync
// Deno Deploy runtime

import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const corsHeaders = {
    "Access-Control-Allow-Origin": "*",
    "Access-Control-Allow-Headers":
        "authorization, x-client-info, apikey, content-type, x-checksum-sha256, x-blob-version",
};

serve(async (req: Request) => {
    // CORS preflight
    if (req.method === "OPTIONS") {
        return new Response("ok", { headers: corsHeaders });
    }

    try {
        // Auth: Extract user from JWT
        const authHeader = req.headers.get("Authorization");
        if (!authHeader) {
            return new Response(
                JSON.stringify({ error: "Missing authorization header" }),
                { status: 401, headers: { ...corsHeaders, "Content-Type": "application/json" } }
            );
        }

        const supabase = createClient(
            Deno.env.get("SUPABASE_URL") ?? "",
            Deno.env.get("SUPABASE_ANON_KEY") ?? "",
            { global: { headers: { Authorization: authHeader } } }
        );

        const { data: { user }, error: authError } = await supabase.auth.getUser();
        if (authError || !user) {
            return new Response(
                JSON.stringify({ error: "Unauthorized" }),
                { status: 401, headers: { ...corsHeaders, "Content-Type": "application/json" } }
            );
        }

        // ─── POST: Push encrypted blob ───
        if (req.method === "POST") {
            const body = await req.json();
            const { data_blob, checksum, device_id, blob_version } = body;

            if (!data_blob || !checksum) {
                return new Response(
                    JSON.stringify({ error: "Missing required fields: data_blob, checksum" }),
                    { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } }
                );
            }

            // Check blob size (max 10MB)
            const blobSize = new Blob([data_blob]).size;
            if (blobSize > 10 * 1024 * 1024) {
                return new Response(
                    JSON.stringify({ error: "Blob exceeds 10MB limit" }),
                    { status: 413, headers: { ...corsHeaders, "Content-Type": "application/json" } }
                );
            }

            // Version conflict check
            const { data: existing } = await supabase
                .from("encrypted_user_data")
                .select("blob_version")
                .eq("user_id", user.id)
                .single();

            const newVersion = blob_version || 1;
            if (existing && existing.blob_version >= newVersion) {
                return new Response(
                    JSON.stringify({
                        error: "Version conflict",
                        server_version: existing.blob_version,
                        client_version: newVersion,
                    }),
                    { status: 409, headers: { ...corsHeaders, "Content-Type": "application/json" } }
                );
            }

            // Upsert encrypted data
            const { error: upsertError } = await supabase
                .from("encrypted_user_data")
                .upsert({
                    user_id: user.id,
                    data_blob: data_blob,
                    checksum: checksum,
                    blob_version: newVersion,
                    size_bytes: blobSize,
                    last_device_sync: new Date().toISOString(),
                });

            if (upsertError) {
                return new Response(
                    JSON.stringify({ error: upsertError.message }),
                    { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } }
                );
            }

            // Update sync metadata
            if (device_id) {
                await supabase.from("sync_metadata").upsert({
                    user_id: user.id,
                    device_id: device_id,
                    last_sync_at: new Date().toISOString(),
                    sync_version: newVersion,
                });
            }

            return new Response(
                JSON.stringify({ success: true, blob_version: newVersion, synced_at: new Date().toISOString() }),
                { status: 200, headers: { ...corsHeaders, "Content-Type": "application/json" } }
            );
        }

        // ─── GET: Pull encrypted blob or metadata ───
        if (req.method === "GET") {
            const url = new URL(req.url);
            const action = url.searchParams.get("action");

            // Metadata only (lightweight version check)
            if (action === "metadata") {
                const { data, error } = await supabase
                    .from("encrypted_user_data")
                    .select("blob_version, updated_at, size_bytes")
                    .eq("user_id", user.id)
                    .single();

                if (error && error.code !== "PGRST116") {
                    return new Response(
                        JSON.stringify({ error: error.message }),
                        { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } }
                    );
                }

                return new Response(
                    JSON.stringify(data ?? { blob_version: 0, updated_at: null, size_bytes: 0 }),
                    { status: 200, headers: { ...corsHeaders, "Content-Type": "application/json" } }
                );
            }

            // Full pull
            const { data, error } = await supabase
                .from("encrypted_user_data")
                .select("data_blob, blob_version, checksum, updated_at")
                .eq("user_id", user.id)
                .single();

            if (error) {
                if (error.code === "PGRST116") {
                    return new Response(
                        JSON.stringify({ exists: false }),
                        { status: 200, headers: { ...corsHeaders, "Content-Type": "application/json" } }
                    );
                }
                return new Response(
                    JSON.stringify({ error: error.message }),
                    { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } }
                );
            }

            return new Response(
                JSON.stringify({ exists: true, ...data }),
                { status: 200, headers: { ...corsHeaders, "Content-Type": "application/json" } }
            );
        }

        return new Response(
            JSON.stringify({ error: "Method not allowed" }),
            { status: 405, headers: { ...corsHeaders, "Content-Type": "application/json" } }
        );

    } catch (error) {
        return new Response(
            JSON.stringify({ error: error.message }),
            { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } }
        );
    }
});
