import org.gradle.api.tasks.Delete
import org.gradle.kotlin.dsl.register

// This is the modern, "future-proof" way to define the custom build directory.
// Instead of using `file()` which is evaluated immediately, this uses the `layout`
// API to create a lazy `Provider`. This is more efficient and avoids circular
// dependency errors because the path isn't fully resolved until it's needed.
val customBuildDirProvider = layout.projectDirectory.dir("../build")

// Assign the root project’s build directory using the lazy provider.
layout.buildDirectory.set(customBuildDirProvider)

// Configure all subprojects.
subprojects {
    // Each subproject’s build directory is set to a subdirectory within the custom build directory.
    // This also uses the lazy provider, making it efficient.
    layout.buildDirectory.set(customBuildDirProvider.dir(project.name))

    // This is a good practice to ensure the 'app' module is configured before others
    // that might depend on it, preventing potential evaluation order issues.
    if (project.name != "app") {
        evaluationDependsOn(":app")
    }
}

// The clean task is updated to delete the directory specified by our lazy provider.
tasks.register<Delete>("clean") {
    delete(customBuildDirProvider)
}

