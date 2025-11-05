package com.kaizeneka.nk

import android.content.Context
import androidx.compose.runtime.Composable
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.dp
import androidx.glance.GlanceId
import androidx.glance.GlanceModifier
import androidx.glance.action.ActionParameters
import androidx.glance.action.clickable
import androidx.glance.appwidget.GlanceAppWidget
import androidx.glance.appwidget.action.ActionCallback
import androidx.glance.appwidget.action.actionRunCallback
import androidx.glance.appwidget.provideContent
import androidx.glance.background
import androidx.glance.layout.Alignment
import androidx.glance.layout.Box
import androidx.glance.layout.Column
import androidx.glance.layout.Row
import androidx.glance.layout.fillMaxWidth
import androidx.glance.layout.padding
import androidx.glance.text.Text
import androidx.glance.text.TextAlign
import androidx.glance.text.TextStyle
import androidx.glance.unit.ColorProvider

class AppWidget : GlanceAppWidget() {

    override suspend fun provideGlance(context: Context, id: GlanceId) {
        provideContent {
            GlanceContent(context)
        }
    }

    @Composable
    private fun GlanceContent(context: Context) {
        Box(modifier = GlanceModifier
            .background(Color(0xFF333333))
            .padding(12.dp)) {
            // Tres botones en fila centrados
            Row(
                modifier = GlanceModifier.fillMaxWidth(),
                verticalAlignment = Alignment.CenterVertically
            ) {
                // Botón Hábitos
                Box(
                    modifier = GlanceModifier
                        .background(Color(0xFF000000))
                        .padding(12.dp)
                        .clickable(actionRunCallback<OpenHabitsAction>())
                ) {
                    Column(horizontalAlignment = Alignment.CenterHorizontally) {
                        Text(
                            "🔄",
                            style = TextStyle(color = ColorProvider(Color(0xFF4CAF50)))
                        )
                        Text(
                            "Hábitos",
                            style = TextStyle(
                                color = ColorProvider(Color.White),
                                textAlign = TextAlign.Center
                            )
                        )
                    }
                }

                // Espacio
                Box(modifier = GlanceModifier.padding(horizontal = 8.dp)) {}

                // Botón Tareas
                Box(
                    modifier = GlanceModifier
                        .background(Color(0xFF000000))
                        .padding(12.dp)
                        .clickable(actionRunCallback<OpenTasksAction>())
                ) {
                    Column(horizontalAlignment = Alignment.CenterHorizontally) {
                        Text(
                            "📝",
                            style = TextStyle(color = ColorProvider(Color(0xFF2196F3)))
                        )
                        Text(
                            "Tareas",
                            style = TextStyle(
                                color = ColorProvider(Color.White),
                                textAlign = TextAlign.Center
                            )
                        )
                    }
                }

                // Espacio
                Box(modifier = GlanceModifier.padding(horizontal = 8.dp)) {}

                // Botón Misiones
                Box(
                    modifier = GlanceModifier
                        .background(Color(0xFF000000))
                        .padding(12.dp)
                        .clickable(actionRunCallback<OpenMissionsAction>())
                ) {
                    Column(horizontalAlignment = Alignment.CenterHorizontally) {
                        Text(
                            "🎯",
                            style = TextStyle(color = ColorProvider(Color(0xFF9C27B0)))
                        )
                        Text(
                            "Misiones",
                            style = TextStyle(
                                color = ColorProvider(Color.White),
                                textAlign = TextAlign.Center
                            )
                        )
                    }
                }
            }
        }
    }
}

class OpenHabitsAction : ActionCallback {
    override suspend fun onAction(context: Context, glanceId: GlanceId, parameters: ActionParameters) {
        // Abrir la app normalmente - la navegación se maneja desde Flutter
        val intent = context.packageManager.getLaunchIntentForPackage(context.packageName)
        intent?.addFlags(android.content.Intent.FLAG_ACTIVITY_NEW_TASK or android.content.Intent.FLAG_ACTIVITY_CLEAR_TOP)
        intent?.putExtra("open_tab", 0)
        context.startActivity(intent)
    }
}

class OpenTasksAction : ActionCallback {
    override suspend fun onAction(context: Context, glanceId: GlanceId, parameters: ActionParameters) {
        // Abrir la app normalmente - la navegación se maneja desde Flutter
        val intent = context.packageManager.getLaunchIntentForPackage(context.packageName)
        intent?.addFlags(android.content.Intent.FLAG_ACTIVITY_NEW_TASK or android.content.Intent.FLAG_ACTIVITY_CLEAR_TOP)
        intent?.putExtra("open_tab", 1)
        context.startActivity(intent)
    }
}

class OpenMissionsAction : ActionCallback {
    override suspend fun onAction(context: Context, glanceId: GlanceId, parameters: ActionParameters) {
        // Abrir la app normalmente - la navegación se maneja desde Flutter
        val intent = context.packageManager.getLaunchIntentForPackage(context.packageName)
        intent?.addFlags(android.content.Intent.FLAG_ACTIVITY_NEW_TASK or android.content.Intent.FLAG_ACTIVITY_CLEAR_TOP)
        intent?.putExtra("open_tab", 2)
        context.startActivity(intent)
    }
}