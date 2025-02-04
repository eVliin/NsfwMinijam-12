# Stockings Naughtymare - Developer Documentation

**Stockings Naughtymare** is an atmospheric narrative-driven game built with [Godot 4.3](https://godotengine.org) and [Dialogic 2](https://docs.dialogic.pro). This documentation is intended to help new developers understand the project structure, core modules, and development workflow so they can start contributing effectively.

---

## Table of Contents

- [Project Overview](#project-overview)
- [Project Structure](#project-structure)
- [Core Modules and Scripts](#core-modules-and-scripts)
  - [Main Game Controller (`main.gd`)](#main-game-controller-maingd)
  - [Main Scene (`main.tscn`)](#main-scene-maintscn)
  - [Global State Management (`Global.gd`)](#global-state-management-globalgd)
  - [Signal Bus (`SignalBus.gd`)](#signal-bus-signalbusgd)
  - [Scene Manager & Transition Controller](#scene-manager--transition-controller)
  - [Custom Portraits Integration](#custom-portraits-integration)
- [Dialogue Integration with Dialogic](#dialogue-integration-with-dialogic)
- [Setting Up Room Scenes](#setting-up-room-scenes)
- [Additional Assets and Configuration](#additional-assets-and-configuration)
- [Development Workflow](#development-workflow)
- [Contributing Guidelines](#contributing-guidelines)
- [References](#references)

---

## Project Overview

**Stockings Naughtymare** is a game where you awaken in a mysterious, eerie mansion after striking a dangerous deal with Mary—a seductive yet terrifying Christmas spirit. The gameplay is driven by interactive dialogue, puzzle-solving, and smooth scene transitions. Dialogic 2 is used for dynamic narrative events, while Godot 4.3 powers the game’s core systems.

---

## Project Structure

The repository follows a standard Godot project layout:

- **/Assets/**  
  Contains art assets (images, fonts, shaders, etc.) used by the game.
  
- **/Autoload/**  
  Contains global scripts (autoload singletons) that include:
  - `Global.gd` – Manages the overall game state.
  - `SignalBus.gd` – Central hub for cross-module event signaling.
  - `/SceneManager/scene_manager.gd` – Handles scene transitions.
  
- **/addons/dialogic/**  
  Contains the Dialogic add-on along with supporting modules (e.g., custom portraits).
  
- **main.gd**  
  The main game controller script, handling scene transitions, input, and pause functionality.
  
- **main.tscn**  
  The main scene that sets up the node hierarchy for the 2D world, HUD, GUI, and loading transitions.
  
- **project.godot**  
  The Godot project configuration file (includes autoload settings, input mappings, and display settings).
  
- **.gitignore**  
  Configures ve
