allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.set(newBuildDir) // Menggunakan set() daripada value()

subprojects {
    val newSubprojectBuildDir = newBuildDir.dir(project.name)
    project.layout.buildDirectory.set(newSubprojectBuildDir) // Menggunakan set() daripada value()

    project.evaluationDependsOn(":app") // Gabungkan evaluasi dependencies
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
