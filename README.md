# My Personal Valorant Analysis App
Between school and family life, I don't have a ton of time to play video games.
But I've fallen in love with Valorant, and I intend to climb ranked as
efficiently as possible. To that end, I've aggregated 
[data on every ranked game](https://docs.google.com/spreadsheets/d/1EdN0USO2oTRaY77LUpduruFPNn_00L8Ea8wjGBiZybY/edit?usp=sharing)
that I've ever played in the hopes that I can direct my practice to the 
situations where I am the weakest and that have the largest statistical impact
on my odds of victory. This app is my attempt at automating some of that
analysis.

### Using the app for your own climb.
The app will use column names from my specific dataset. You are welcome and
encouraged to collect your own data and use this app yourself, but I cannot
guarantee its performance, and you'll need to use identical column names to
mine. If you try it and something goes wrong, feel free to reach out with a
GitHub issue, or find me on Discord!

### Running the app
To use the app, open this repository in RStudio. Navigate to your console and
type the following:
```
library(shiny)
runApp("app")
```
*Note: If you're missing any R packages you'll get an error message. Install*
*those packages and try again.*
