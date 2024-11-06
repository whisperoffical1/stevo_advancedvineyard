Hello all, **I do not own this script**, This script is owned by [stevo], I have simply published the installation tutorial here for you, This is the installation for **QB-CORE** so if you need to install for **ESX** or **Qbox** then please resort to his [Installation Guide](https://docs.stevoscripts.com/free-scripts/stevo_advancedvineyard)

## Grape Picking and Wine Making 🍇🍷

Players can pick grapes, crush them and make their own fine wines! The script is highly configurable, allowing you to alter aspects to suit the exact needs of your server.

- Supports ESX, Qbox and QBCore.
- Supports all inventories.
- Supports ox_target, qb-target and interact.
- Locales: English, Español, Dutch, Estonian, French

**Preview:** [Click Here](https://youtu.be/M7LS4ngOCoY)
<br>
**Download:** [Click Here](https://github.com/stevoscriptsteam/stevo_advancedvineyard/releases/tag/1.0.0)

Installation guide: [Click Here](https://docs.stevoscripts.com/free-scripts/stevo_advancedvineyard)
<br>
Forum post: [Click Here]()

**Dependencies:**
[stevo_lib](https://github.com/stevoscriptsteam/stevo_lib)
[ox_lib](https://github.com/overextended/ox_lib)

## INSTALLATION:

Download the latest of this script, Then drag and drop into your resources where ever you usually put your scripts.

Then Open the **stevo_advancedvineyard** folder and open the **"IMAGES"** folder, Now copy all of the **images** and head to **[qb]** folder assuming you have **qb-inventory** or your inventory script in the **[qb]** folder, If not, Then go to **YOUR** location of where your inventory is installed at and then open your inventory folder, Next find where you put images, For **qb-inventory** or a similar setup once you open the **qb-inventory** folder then open the **html** folder, Then open the **images** folder, Now paste the **emptywinebottle.png** | **redgrape.png** | **redwinebottle.png** | **whitegrape.png** | **whitewinebottle.png** into the **images** folder, Now go to **[qb]/qb-core/shared/items.lua**, Now scroll to the bottom, Then paste the following into there:

```
-- stevo vineyard items
    whitegrape = { name = 'whitegrape', label = 'White Grape', weight = 10, type = 'item', image = 'whitegrape.png', unique = false, useable = false, shouldClose = true, combinable = nil, description = 'A fresh white grape ready for winemaking.' },
    redgrape = { name = 'redgrape', label = 'Red Grape', weight = 10, type = 'item', image = 'redgrape.png', unique = false, useable = false, shouldClose = true, combinable = nil, description = 'A fresh red grape perfect for making wine.' },
    redwinebottle = { name = 'redwinebottle', label = 'Red Wine', weight = 10, type = 'item', image = 'redwinebottle.png', unique = false, useable = true, shouldClose = true, combinable = nil, description = 'A bottle of rich red wine.' },
    whitewinebottle = { name = 'whitewinebottle', label = 'White Wine', weight = 10, type = 'item', image = 'whitewinebottle.png', unique = false, useable = true, shouldClose = true, combinable = nil, description = 'A bottle of crisp white wine.' },
    emptywinebottle = { name = 'emptywinebottle', label = 'Empty Wine Bottle', weight = 10, type = 'item', image = 'emptywinebottle.png', unique = false, useable = false, shouldClose = true, combinable = nil, description = 'An empty bottle ready for a fresh batch of wine.' },

```
(This is the updated 2024 qb-core items.lua paste format.)

Now restart your server and test out the script, If any issues occur then please resort to leaving a message on the owner's [CFX Forum Page](https://forum.cfx.re/t/free-esx-qb-qbx-advanced-vineyard/5280620)

Remember, This is a forked version, Everything in the script itself should be changed, If theres any errors then once again, Please resort to leaving a message on the owner's [CFX Forum Page](https://forum.cfx.re/t/free-esx-qb-qbx-advanced-vineyard/5280620) as i **WILL NOT** be offering support for this script as it is not my script and i have no ownership over this script.

-- Credits to **StevoScripts** for making this fork possible!!!
