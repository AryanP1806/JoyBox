
allprojects {
    repositories {
        google()
        mavenCentral()
    }
}
buildscript {
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        // Add the Google Services classpath here to make it available to all modules
        classpath("com.google.gms:google-services:4.4.4")
    }
}

// Top-level build file where you can add configuration options common to all sub-projects/modules.
plugins {
    id("dev.flutter.flutter-gradle-plugin") apply false
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
