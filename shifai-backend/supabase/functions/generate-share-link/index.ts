// Supabase Edge Function: generate-share-link
// Creates a 7-day shareable link for medical export PDFs

import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const corsHeaders = {
    "Access-Control-Allow-Origin": "*",
    "Access-Control-Allow-Headers":
        "authorization, x-client-info, apikey, content-type",
};

const EXPORT_BUCKET = "medical-exports";
const LINK_TTL_DAYS = 7;

serve(async (req: Request) => {
    if (req.method === "OPTIONS") {
        return new Response("ok", { headers: corsHeaders });
    }

    try {
        const authHeader = req.headers.get("Authorization");
        if (!authHeader) {
            return new Response(
                JSON.stringify({ error: "Unauthorized" }),
                { status: 401, headers: { ...corsHeaders, "Content-Type": "application/json" } }
            );
        }

        const supabase = createClient(
            Deno.env.get("SUPABASE_URL") ?? "",
            Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "",
            { global: { headers: { Authorization: authHeader } } }
        );

        const { data: { user } } = await supabase.auth.getUser();
        if (!user) {
            return new Response(
                JSON.stringify({ error: "Unauthorized" }),
                { status: 401, headers: { ...corsHeaders, "Content-Type": "application/json" } }
            );
        }

        if (req.method !== "POST") {
            return new Response(
                JSON.stringify({ error: "Method not allowed" }),
                { status: 405, headers: { ...corsHeaders, "Content-Type": "application/json" } }
            );
        }

        // Read PDF binary from request
        const formData = await req.formData();
        const pdfFile = formData.get("pdf") as File;

        if (!pdfFile) {
            return new Response(
                JSON.stringify({ error: "Missing PDF file" }),
                { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } }
            );
        }

        // Generate unique path
        const exportId = crypto.randomUUID();
        const filePath = `${user.id}/${exportId}.pdf`;
        const expiresAt = new Date(Date.now() + LINK_TTL_DAYS * 24 * 60 * 60 * 1000);

        // Upload to private bucket
        const { error: uploadError } = await supabase.storage
            .from(EXPORT_BUCKET)
            .upload(filePath, pdfFile, {
                contentType: "application/pdf",
                upsert: false,
            });

        if (uploadError) {
            return new Response(
                JSON.stringify({ error: uploadError.message }),
                { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } }
            );
        }

        // Create signed URL (7-day expiry)
        const { data: signedUrl, error: signError } = await supabase.storage
            .from(EXPORT_BUCKET)
            .createSignedUrl(filePath, LINK_TTL_DAYS * 24 * 60 * 60);

        if (signError) {
            return new Response(
                JSON.stringify({ error: signError.message }),
                { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } }
            );
        }

        return new Response(
            JSON.stringify({
                share_url: signedUrl.signedUrl,
                export_id: exportId,
                expires_at: expiresAt.toISOString(),
                ttl_days: LINK_TTL_DAYS,
            }),
            { status: 200, headers: { ...corsHeaders, "Content-Type": "application/json" } }
        );

    } catch (error) {
        return new Response(
            JSON.stringify({ error: error.message }),
            { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } }
        );
    }
});
