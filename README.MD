**!!! WORK IN PROGRESS !!!**
<hr>

## Synopsis
WBT is a simple program (barely more than a script at the point of writing) that serves as a shortcut; a more convenient way to integrate changes successfully and deploy Lua-based addons for World of Warcraft with confidence. It also helps with common tasks resembling project management chores that aren't covered by existing tools and commonly neglected by addon authors.

It is written completely in Lua, as most addon authors will be somewhat familiar with it.

## Current Status

WBT is technically usable, but not very polished, nor particularly user-friendly at this point. I'd consider it very, *very* early alpha quality at best (though it's a bit more than a proof-of-concept and has some useful functionality already).

If you're interested in using it to build your own addons, I can probably fix some of that right away - but for now it's not a high priority as I tend to use it for my own build process, and add some small things as I think of them without worrying too much about refining everything.

*PS: To see what is on the horizon, please scroll down to the actual description (which is only a draft at this point) below.*

<hr>

## Implemented Modules

## Locales
* Mostly functional
* Could use better options and some cleanup, but...
* Scraping and exporting generally works)

## StaticAnalysis
* Basic syntax check only

## UnitTesting
* Basic luaunit support with somewhat specific structural requirements

<hr>

## Disclaimer

*Detailed readme below - Note: This is a first draft and will be formatted properly later. Not all functionality is implemented, by far!*

<hr>

**Project:** WBT (WoW Build Tools)

**Title:** Toolkit for automating builds and routine tasks commonly encountered while developing addons for World of Warcraft

<hr>

## Description

**WBT** (short for: (World of) **W**arcraft **B**uild **T**ools) is a simple program (barely more than a script at the point of writing) that serves as a shortcut; a more convenient way to integrate changes successfully and deploy Lua-based addons for World of Warcraft with confidence. It also helps with common tasks more closely resembling project management chores that aren't covered by existing tools and commonly neglected by addon authors. It is written completely in Lua, as most addon authors will be somewhat familiar with it.

While it attempts to provide an interface for any task related to WOW addon development, the core is built to be modular, allowing you to run selected modules and customise your deployment and build processes according to your needs.

## Modules Overview

### Locales
* Underlying: Custom Scrapewhale app (locales scraper and file exporter)
* Scrapes lua files for phrases that need to be localised
* Uploads them to CurseForge project sites, where they can be accessed by translators as soon as you deploy pre-release versions (API key required)
* Configuration to exlude files, directories, or manually set list of files using standard Lua

### UnitTests
* Underlying: LuaUnit library (established unit testing framework for Lua programs)
* Luaunit interface and custom summary / output in formats more closely representing WOW

### StaticAnalysis
* Underlying: Luacheck library (established linter for Lua programs)
* Luacheck support and configuration utility (same global config can be used to define addon folders, set ignored files, etc. as for the localization)
* Modes: Verbose, minimal (pass)
* Embed globals in source (WA2 etc.?) -> -- luacheck global1 global 2 ... globaln to be automatically added -> obsolete if shared config (luaunit has mock api with list of globals)

### ChangeLogs
* Underlying: Custom LogPickr app (changelog generation script)
* Automatically update and manage changelog files that can be used on project sites, shipped alongside builds, or kept for archiving purposes
* Formatting templates (predefined or custom styles)
* Supports HTML or Markdown syntax

## Versioning
* Underlying: NYI
* Manage versions (alpha, beta, release) and number builds automatically according to custom or predefined schemes (semantic versioning, subversion, git hash?)

### CodeStandards
* Underlying: NYI
* Check for indentation and similar formatting options to improve readability (luaformatter, all indents and purposes?)

### Documentation
* Underlying: LDoc library (established documentation generation tool for Lua programs)
* Updates documentation
* Detects undocumented functionality and mismatching descriptions

## Usage and customization

### Config file
* There are technically two main configuration files, but CurseConfig.lua is only required to access the CurseForge website (which requires a valid API key)
* The <ModuleName>Config.lua files contain advanced functionality you may be interested in when using the the respective module. The default values should suffice in many cases
* Config.lua allows setting of global parameters that control which modules are ran, and how
* It is possible to customise the builder to only run specific modules, and this can even be done from another lua program (or via the command-line interface - see below)
* All files are written in Lua and can be exectued locally, included in another script, or on a remote CI environment (TravisCI, AppVeyor, ...)

## Command Line Interface
* Provide WowBuildTools with typical command line arguments
* Allows selecting individual modules to be run, which addon/program to build