# odin tutorial

[odin-docs](https://odin-lang.org/docs/)

couple of examples for writing odin code 

## install odin
  1. go to [odin-website](https://odin-lang.org/docs/install/#official-releases)
  2. click `Latest Release`
  3. download newest version of `odin-windows-amd64-<version>.zip`
  4. make folder `C:\workspace\odin\odin`
  5. extract contents of downloaded zip into that folder
      - make sure you cut and paste so that `odin.exe` is in the `C:\workspace\odin\odin` folder
  6. search in windows search bar for `Advanced System Settings` or `Erweiterte Systemeinstellungen`
  7. click the bottom most button `english idk` or `Systemvariablen`
  8. on the bottom half under `english idk` or `Systemvariablen` double click `Path`
  9. add new system variable `C:\workspace\odin\odin`
  10. open or restart your terminal and enter the command: `odin version`
      - should get something back like `odin version dev-2026-09-nightly:a2fb372`
      - if you get back something like `english idk` or `Der Befehl "odin" ist entweder falsch geschrieben oder konnte nicht gefunden werden.`, then ask me for help or redo all the steps, maybe restart your computer first, sometimes windows needs it


## make a project
  1. make folder in your `C:\workspace\odin` folder
  2. make a `main.odin` file
  3. copy paste the following text into it
  ```odin
  package main
  
  import "core:fmt"
  
  
  main :: proc()
  {
    fmt.println( "hello world !!!" )
  }
  ```
  4. make a `build.bat` file in the same folder and copy paste the following
  ```batch
  @echo off
  
  odin run . -debug
  ```
  5. open terminal and `cd` into newly created folder, then call `build`
