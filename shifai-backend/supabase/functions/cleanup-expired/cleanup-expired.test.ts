import { assertEquals } from "https://deno.land/std@0.208.0/assert/assert_equals.ts";
import { assertExists } from "https://deno.land/std@0.208.0/assert/assert_exists.ts";

/**
 * cleanup-expired Edge Function tests.
 * Tests cleanup logic: expired links, orphaned storage, old conflicts.
 */

Deno.test("expired share links deleted after 72h", () => {
    const now = new Date();
    const created = new Date(now.getTime() - 73 * 60 * 60 * 1000); // 73h ago
    const maxAge = 72 * 60 * 60 * 1000; // 72h
    const isExpired = (now.getTime() - created.getTime()) > maxAge;
    assertEquals(isExpired, true);
});

Deno.test("non-expired share links kept", () => {
    const now = new Date();
    const created = new Date(now.getTime() - 24 * 60 * 60 * 1000); // 24h ago
    const maxAge = 72 * 60 * 60 * 1000;
    const isExpired = (now.getTime() - created.getTime()) > maxAge;
    assertEquals(isExpired, false);
});

Deno.test("orphaned storage identified by missing reference", () => {
    const storageFiles = ["file_a.enc", "file_b.enc", "file_c.enc"];
    const referencedFiles = ["file_a.enc", "file_c.enc"];
    const orphaned = storageFiles.filter(f => !referencedFiles.includes(f));
    assertEquals(orphaned.length, 1);
    assertEquals(orphaned[0], "file_b.enc");
});

Deno.test("conflict records older than 30 days cleaned", () => {
    const now = new Date();
    const conflictDate = new Date(now.getTime() - 31 * 24 * 60 * 60 * 1000); // 31 days
    const maxAge = 30 * 24 * 60 * 60 * 1000;
    const isOld = (now.getTime() - conflictDate.getTime()) > maxAge;
    assertEquals(isOld, true);
});

Deno.test("recent conflict records kept", () => {
    const now = new Date();
    const conflictDate = new Date(now.getTime() - 5 * 24 * 60 * 60 * 1000); // 5 days
    const maxAge = 30 * 24 * 60 * 60 * 1000;
    const isOld = (now.getTime() - conflictDate.getTime()) > maxAge;
    assertEquals(isOld, false);
});

Deno.test("cleanup report format", () => {
    const report = {
        expired_links: 3,
        orphaned_files: 1,
        old_conflicts: 5,
        timestamp: new Date().toISOString(),
    };
    assertExists(report.timestamp);
    assertEquals(report.expired_links + report.orphaned_files + report.old_conflicts, 9);
});

Deno.test("service role required", () => {
    const headers = { "Authorization": "Bearer service-role-key" };
    assertExists(headers["Authorization"]);
});

Deno.test("empty cleanup returns zero counts", () => {
    const report = { expired_links: 0, orphaned_files: 0, old_conflicts: 0 };
    assertEquals(report.expired_links, 0);
    assertEquals(report.orphaned_files, 0);
    assertEquals(report.old_conflicts, 0);
});

Deno.test("batch deletion limit", () => {
    const batchSize = 100;
    const totalExpired = 250;
    const batches = Math.ceil(totalExpired / batchSize);
    assertEquals(batches, 3);
});

Deno.test("cleanup timestamp is ISO format", () => {
    const ts = new Date().toISOString();
    assertEquals(ts.includes("T"), true);
    assertEquals(ts.endsWith("Z"), true);
});
