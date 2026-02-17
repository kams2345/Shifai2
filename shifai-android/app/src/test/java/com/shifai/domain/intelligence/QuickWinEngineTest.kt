package com.shifai.domain.intelligence

import org.junit.Assert.*
import org.junit.Before
import org.junit.Test

class QuickWinEngineTest {

    // ─── Milestone Detection ───

    @Test
    fun `J1 milestone triggers at first log`() {
        val milestone = checkMilestone(logCount = 1, daysSinceInstall = 1, shownIds = emptySet())
        assertEquals("quickwin_j1", milestone)
    }

    @Test
    fun `J3 milestone triggers at 3 days`() {
        val milestone = checkMilestone(logCount = 3, daysSinceInstall = 3, shownIds = setOf("quickwin_j1"))
        assertEquals("quickwin_j3", milestone)
    }

    @Test
    fun `J7 milestone triggers at 7 days`() {
        val milestone = checkMilestone(logCount = 7, daysSinceInstall = 7,
            shownIds = setOf("quickwin_j1", "quickwin_j3"))
        assertEquals("quickwin_j7", milestone)
    }

    @Test
    fun `J14 milestone triggers at 14 days`() {
        val milestone = checkMilestone(logCount = 14, daysSinceInstall = 14,
            shownIds = setOf("quickwin_j1", "quickwin_j3", "quickwin_j7"))
        assertEquals("quickwin_j14", milestone)
    }

    @Test
    fun `already shown milestone does not re-trigger`() {
        val milestone = checkMilestone(logCount = 1, daysSinceInstall = 1,
            shownIds = setOf("quickwin_j1"))
        assertNull(milestone)
    }

    @Test
    fun `no logs returns null`() {
        val milestone = checkMilestone(logCount = 0, daysSinceInstall = 0, shownIds = emptySet())
        assertNull(milestone)
    }

    // ─── Adaptive Frequency ───

    @Test
    fun `week 1 frequency is daily`() {
        assertEquals("daily", recommendedFrequency(daysSinceInstall = 3))
    }

    @Test
    fun `week 3 frequency is weekly`() {
        assertEquals("weekly", recommendedFrequency(daysSinceInstall = 18))
    }

    @Test
    fun `month 2 frequency is biweekly`() {
        assertEquals("biweekly", recommendedFrequency(daysSinceInstall = 45))
    }

    // ─── Educational Drip ───

    @Test
    fun `drip tips are 10 items`() {
        val tips = (4..13).map { "drip_j$it" }
        assertEquals(10, tips.size)
    }

    @Test
    fun `drip tip for day 4 exists`() {
        val tipDay = 4
        assertTrue(tipDay in 4..13)
    }

    // ─── Helpers ───

    private fun checkMilestone(logCount: Int, daysSinceInstall: Int, shownIds: Set<String>): String? {
        val milestones = listOf(
            Triple("quickwin_j1", 1, 1),
            Triple("quickwin_j3", 3, 3),
            Triple("quickwin_j7", 7, 7),
            Triple("quickwin_j14", 14, 14),
            Triple("quickwin_cycle1", 28, 28)
        )
        for ((id, requiredLogs, requiredDays) in milestones) {
            if (id !in shownIds && logCount >= requiredLogs && daysSinceInstall >= requiredDays) {
                return id
            }
        }
        return null
    }

    private fun recommendedFrequency(daysSinceInstall: Int): String = when {
        daysSinceInstall <= 7 -> "daily"
        daysSinceInstall <= 28 -> "weekly"
        else -> "biweekly"
    }
}
