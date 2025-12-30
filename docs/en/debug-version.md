# What is a debug version?

If you encounter an error in the program, developers need **detailed information about the crash** to fix it. For this, we have a **debug version** of the program.

The debug version is a special version of the program designed for finding and fixing errors. Unlike the regular **release version**, which simply closes or shows a generic crash message, the debug version creates a **detailed report** with information about what exactly went wrong.

Our **[nightly builds](https://github.com/sasgis/sas.planet.src/releases/tag/nightly)** include two versions of the program:

  * `SASPlanet.exe` — the **regular (release)** version. It runs faster, but when an error occurs, it only shows a generic message.
  * `SASPlanet.Debug.exe` — the **debug** version. It is needed to find and fix errors. When it crashes, it collects a detailed report that is very helpful for developers.

# How to use the debug version?

1. **[Download the nightly build](https://github.com/sasgis/sas.planet.src/releases/tag/nightly).** If the error was found in the **stable version** of the program, you need to download the latest **nightly build** and reproduce the error in it (the debug version is only available in nightly builds).
2. **Run** `SASPlanet.Debug.exe`.
3. **Reproduce the error.** Perform the same actions that led to the crash the first time. When the error occurs, the debug version will show a special window.

Example of an error window in the release version:

![](assets/debug_version_msg_win.png)

Example of an error window in the debug version:

![](assets/debug_version_msg_me1.png)

This window has several buttons:

* `show bug report` — This button opens a window with detailed technical information about the crash. This information is very important for developers.
* `continue application` — The program will try to continue running, ignoring the error. This may lead to unstable operation or another crash.
* `restart application` — The program will close and start again.
* `close application` — The program will be forcibly closed.

Example of a window with a detailed report in the debug version:

![](assets/debug_version_msg_me2.png)

4. **Find the report file.** The debug version automatically creates a **`bugreport.txt`** file in the same folder where `SASPlanet.Debug.exe` is located.
5. **Create a ticket in the [Bugtracker](https://www.sasgis.org/mantis/my_view_page.php).** Attach the following to it:
    * The **`bugreport.txt`** file.
    * Explanatory **screenshots**, links to **videos** of the error reproduction.
    * **Detailed steps** to reproduce the error. The more accurately you describe what you did, the faster it will be fixed.

Submitting a report is the easiest and fastest way to help us improve the program. Thank you for your contribution!