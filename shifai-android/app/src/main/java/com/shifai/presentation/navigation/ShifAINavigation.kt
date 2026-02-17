package com.shifai.presentation.navigation

import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.res.stringResource
import androidx.navigation.NavHostController
import androidx.navigation.compose.*
import com.shifai.R
import com.shifai.presentation.dashboard.DashboardScreen
import com.shifai.presentation.insights.InsightsScreen
import com.shifai.presentation.settings.SettingsScreen
import com.shifai.presentation.tracking.TrackingScreen

/**
 * Navigation — Compose NavHost with bottom navigation.
 * 4 tabs: Dashboard, Tracking, Insights, Settings.
 * Mirrors iOS MainTabView.swift.
 */

sealed class Route(val path: String, val labelRes: Int, val icon: String) {
    object Dashboard : Route("dashboard", R.string.tab_dashboard, "chart_line")
    object Tracking : Route("tracking", R.string.tab_tracking, "add_circle")
    object Insights : Route("insights", R.string.tab_insights, "psychology")
    object Settings : Route("settings", R.string.tab_settings, "settings")

    companion object {
        val tabs = listOf(Dashboard, Tracking, Insights, Settings)
    }
}

@Composable
fun ShifAINavHost(navController: NavHostController) {
    NavHost(
        navController = navController,
        startDestination = Route.Dashboard.path
    ) {
        composable(Route.Dashboard.path) { DashboardScreen() }
        composable(Route.Tracking.path) { TrackingScreen() }
        composable(Route.Insights.path) { InsightsScreen() }
        composable(Route.Settings.path) { SettingsScreen() }
    }
}

@Composable
fun ShifAIBottomBar(navController: NavHostController) {
    val navBackStackEntry by navController.currentBackStackEntryAsState()
    val currentRoute = navBackStackEntry?.destination?.route

    NavigationBar {
        Route.tabs.forEach { route ->
            NavigationBarItem(
                selected = currentRoute == route.path,
                onClick = {
                    navController.navigate(route.path) {
                        popUpTo(Route.Dashboard.path) { saveState = true }
                        launchSingleTop = true
                        restoreState = true
                    }
                },
                label = { Text(stringResource(route.labelRes)) },
                icon = { /* Material icon based on route.icon */ }
            )
        }
    }
}
