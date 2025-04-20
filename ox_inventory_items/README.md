# **Aliano Alcohol System - OX Inventory Setup Guide**

## 📦 Required Items Installation

This guide explains how to add the alcohol items to your OX Inventory without breaking the script functionality.

### ⚠️ Important Warnings

1. **DO NOT** modify the item names - the script relies on these exact identifiers
2. **DO NOT** change the `consume` or `degrade` values
3. Keep all `event` references intact

## 🍾 Alcohol Items to Add

Copy and paste this entire block into your `ox_inventory/data/items.lua`:

```lua
	--- ALCOOLS UTILISABLES - USABLE ALCOHOLS ---
	['ambeer'] = {
		label = "Am'Beer",
		weight = 500,
		consume = 0,
		client = {
			event = 'aliano_alcohol_effect:startDrinking'
		}
	},
	['beer'] = {
		label = "Bière",
		weight = 500,
		consume = 0,
		client = {
			event = 'aliano_alcohol_effect:startDrinking'
		}
	},
	['corona'] = {
		label = "Corona",
		weight = 500,
		consume = 0,
		client = {
			event = 'aliano_alcohol_effect:startDrinking'
		}
	},
	['housered'] = {
		label = "Housered",
		weight = 500,
		consume = 0,
		client = {
			event = 'aliano_alcohol_effect:startDrinking'
		}
	},
	['jack_daniels'] = {
		label = "Jack Daniels",
		weight = 500,
		consume = 0,
		client = {
			event = 'aliano_alcohol_effect:startDrinking'
		}
	},
	['pisswaser1'] = {
		label = "Pisswaser brune",
		weight = 500,
		consume = 0,
		client = {
			event = 'aliano_alcohol_effect:startDrinking'
		}
	},
	['pisswaser2'] = {
		label = "Pisswaser blanche",
		weight = 500,
		consume = 0,
		client = {
			event = 'aliano_alcohol_effect:startDrinking'
		}
	},
	['pisswaser3'] = {
		label = "Pisswaser noire",
		weight = 500,
		consume = 0,
		client = {
			event = 'aliano_alcohol_effect:startDrinking'
		}
	},
	['schnapps'] = {
		label = "Schnapps",
		weight = 500,
		consume = 0,
		client = {
			event = 'aliano_alcohol_effect:startDrinking'
		}
	},
	['stronzo_beer'] = {
		label = "Stronzo Beer",
		weight = 500,
		consume = 0,
		client = {
			event = 'aliano_alcohol_effect:startDrinking'
		}
	},
	['vodka'] = {
		label = "Vodka",
		weight = 500,
		consume = 0,
		client = {
			event = 'aliano_alcohol_effect:startDrinking'
		}
	},
	['cervenaflasa'] = {
		label = 'Vin rouge',
		weight = 250,
		stack = true,
		close = true,
		consume = 0,
		client = {
			event = 'aliano_alcohol_effect:startDrinking'
		}
	},

	['bielaflasa'] = {
		label = 'Vin blanc',
		weight = 250,
		stack = true,
		close = true,
		consume = 0,
		client = {
			event = 'aliano_alcohol_effect:startDrinking'
		}
	},

	['ruzovaflasa'] = {
		label = 'Vin rosé',
		weight = 250,
		stack = true,
		close = true,
		consume = 0,
		client = {
			event = 'aliano_alcohol_effect:startDrinking'
		}
	},
```

## 🖼️ Required Images

1. Place these PNG files in `ox_inventory/web/images/`:

   - beer.png
   - vodka.png
   - whiskey.png
   - [13 other alcohol images]

2. Image specifications:
   - Format: 64x64 pixels
   - Transparent background
   - Clear product visibility

## 🔧 Post-Installation Steps

1. Restart your server
2. Ensure all items appear in OX Inventory
3. Verify props appear correctly when drinking

## ❌ Common Mistakes to Avoid

- Changing item names (will break the script)
- Modifying the consume/degrade values
- Using incorrect image sizes/formats
- Forgetting to restart after adding items

_Maintain the immersive experience by keeping all item identifiers exactly as provided!_
