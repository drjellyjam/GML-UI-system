# Kennal-UI-system
UI system for gamemaker written in GML

Originally made for a old project.
Its not the best but its simple, easy to use, has no dependencies and works.

Has support for buttons, text labels, toggles, textboxes

# Usage example
```
ui = new Ui(0,0,640,320) //base ui panel

//example of ui elements
unsaveddialog = new UiElement(0.5,0.5,0,0,0.25,0,8,24+8+4,0.5,0.5)
unsaveddialog.text = "are you sure?"
unsaveddialog.text_yscale = 0.25
unsaveddialog.is_visible = false

unsaveddialog_yes = new UiElement(0,1,4,-4,0.5,0,-6,12,0,1)
unsaveddialog_yes.text = "yes"
unsaveddialog_yes.is_button = true

unsaveddialog.Add(unsaveddialog_yes)

unsaveddialog_no = new UiElement(1,1,-4,-4,0.5,0,-6,12,1,1)
unsaveddialog_no.text = "no"
unsaveddialog_no.is_button = true

unsaveddialog.Add(unsaveddialog_no)

//add unsaveddialog to base ui panel
ui.Add(unsaveddialog)
```
