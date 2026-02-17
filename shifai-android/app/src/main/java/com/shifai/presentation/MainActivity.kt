package com.shifai.presentation

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.padding
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.navigation.NavGraph.Companion.findStartDestination
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.composable
import androidx.navigation.compose.currentBackStackEntryAsState
import androidx.navigation.compose.rememberNavController
import com.shifai.presentation.dashboard.DashboardScreen
import com.shifai.presentation.export.ExportPreviewScreen
import com.shifai.presentation.insights.InsightsScreen
import com.shifai.presentation.onboarding.OnboardingScreen
import com.shifai.presentation.settings.SettingsScreen
import com.shifai.presentation.tracking.TrackingScreen

private val BgDark = Color(0xFF0F0B1E)
private val Purple = Color(0xFF7C5CFC)
private val NavBg = Color(0xFF1A1530)

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()

        setContent {
            val prefs = getSharedPreferences("shifai_prefs", MODE_PRIVATE)
            val onboardingComplete = prefs.getBoolean("onboarding_complete", false)
            var showOnboarding by remember { mutableStateOf(!onboardingComplete) }

            MaterialTheme(
                colorScheme = darkColorScheme(
                    primary = Purple,
                    background = BgDark,
                    surface = NavBg,
                    onBackground = Color.White,
                    onSurface = Color.White
                )
            ) {
                if (showOnboarding) {
                    OnboardingScreen(
                        onComplete = {
                            prefs.edit().putBoolean("onboarding_complete", true).apply()
                            showOnboarding = false
                        }
                    )
                } else {
                    MainNavigation()
                }
            }
        }
    }
}

// ─── Navigation ───

enum class Screen(val route: String, val label: String, val icon: ImageVector) {
    Dashboard("dashboard", "Dashboard", Icons.Default.Home),
    Tracking("tracking", "Suivi", Icons.Default.AddCircle),
    Insights("insights", "Intelligence", Icons.Default.Lightbulb),
    Export("export", "Export", Icons.Default.Description),
    Settings("settings", "Réglages", Icons.Default.Settings)
}

@Composable
fun MainNavigation() {
    val navController = rememberNavController()
    val navBackStack by navController.currentBackStackEntryAsState()
    val currentRoute = navBackStack?.destination?.route

    Scaffold(
        containerColor = BgDark,
        bottomBar = {
            NavigationBar(
                containerColor = NavBg,
                contentColor = Color.White.copy(alpha = 0.5f)
            ) {
                Screen.entries.forEach { screen ->
                    NavigationBarItem(
                        icon = { Icon(screen.icon, contentDescription = screen.label) },
                        label = { Text(screen.label) },
                        selected = currentRoute == screen.route,
                        onClick = {
                            navController.navigate(screen.route) {
                                popUpTo(navController.graph.findStartDestination().id) {
                                    saveState = true
                                }
                                launchSingleTop = true
                                restoreState = true
                            }
                        },
                        colors = NavigationBarItemDefaults.colors(
                            selectedIconColor = Purple,
                            selectedTextColor = Purple,
                            unselectedIconColor = Color.White.copy(alpha = 0.4f),
                            unselectedTextColor = Color.White.copy(alpha = 0.4f),
                            indicatorColor = Purple.copy(alpha = 0.12f)
                        )
                    )
                }
            }
        }
    ) { innerPadding ->
        NavHost(
            navController = navController,
            startDestination = Screen.Dashboard.route,
            modifier = Modifier
                .fillMaxSize()
                .padding(innerPadding)
        ) {
            composable(Screen.Dashboard.route) { DashboardScreen() }
            composable(Screen.Tracking.route) { TrackingScreen() }
            composable(Screen.Insights.route) { InsightsScreen() }
            composable(Screen.Export.route) { ExportPreviewScreen() }
            composable(Screen.Settings.route) { SettingsScreen() }
        }
    }
}
