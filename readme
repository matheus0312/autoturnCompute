# Autoturn Compute

**Autoturn Compute** is a [KOReader](https://github.com/koreader/koreader) plugin designed to measure and analyze your reading speed. It calculates the average time spent per page and the standard deviation based on your recent reading history, intended to help fine-tune automated page-turn settings.

## Features

* **Real-time Calculation:** Automatically computes the average seconds per page based on your last 10 pages.
* **Smart Filtering:** Ignores outliers to ensure accuracy:
    * Pages read in under **5 seconds** are discarded (assumed to be accidental turns or skimming).
    * Pages taking over **600 seconds** (10 minutes) are discarded (assumed to be interruptions).
* **Standard Deviation:** Calculates the consistency of your reading speed to provide a "±" variance.
* **Visual Feedback:**
    * Displays a popup notification once the initial history (10 pages) is built.
    * Menu item updates dynamically to show the current average.
* **Detailed Stats:** Clicking the stats menu item reveals:
    * Total pages in history.
    * Duration of the very last page read.
    * Current average duration.
    * Standard deviation.

## Installation

1.  Download the `autoturncompute` folder.
2.  Connect your KOReader device to your computer via USB.
3.  Copy the folder into the `koreader/plugins/` directory on your device.
    * *Note: You may need to enable "Show hidden files" on your computer to see the `.adds` or `koreader` folders depending on your device.*
4.  Eject the device and restart KOReader.

## Usage

1.  Open a document in KOReader.
2.  Open the **Main Menu** (tap the top of the screen).
3.  Navigate to **Autoturn Compute**.
4.  **Enable** the plugin using the checkbox.
5.  Read normally. Once you have turned 10 pages (within the valid time window), a popup will display your calculated reading speed.

### Menu Options

* **Enabled:** Toggles the background computation on or off.
* **Avg Page Duration:** Displays the current calculated average and deviation. Tap this to see a detailed breakdown.
* **Reset History:** Clears the stored page durations and resets the calculation buffers.

## Configuration & Logic

* **History Size:** The plugin maintains a rolling history of the last **10** valid page turns.
* **Thresholds:**
    * Minimum: 5 seconds
    * Maximum: 600 seconds

## Todo / Roadmap

* [ ] Change presentation of the widget to be shown below the native Autoturn widget.
* [x] Show page duration on menu.
* [x] Add checkbox on the menu to activate plugin.

## License

[MIT](LICENSE)
