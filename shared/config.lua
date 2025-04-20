Config = {
    Locale = 'fr', -- English 'en' or French 'fr'
    AlcoholItems = {
        'ambeer', 'beer', 'corona', 'housered', 'jack_daniels',
        'pisswaser1', 'pisswaser2', 'pisswaser3', 'schnapps', 
        'stronzo_beer', 'vodka', 'cervenaflasa', 'bielaflasa', 'ruzovaflasa'
    },
    BottleModels = {
        ['ambeer'] = 'prop_beer_am',
        ['beer'] = 'prop_beer_bottle',
        ['corona'] = 'prop_beer_bottle',
        ['housered'] = 'prop_vodka_bottle',
        ['jack_daniels'] = 'prop_whiskey_bottle',
        ['pisswaser1'] = 'prop_beer_bottle',
        ['pisswaser2'] = 'prop_beer_bottle',
        ['pisswaser3'] = 'prop_beer_bottle',
        ['schnapps'] = 'prop_vodka_bottle',
        ['stronzo_beer'] = 'prop_beer_bottle',
        ['vodka'] = 'prop_vodka_bottle',
        ['cervenaflasa'] = 'prop_beer_stz',
        ['bielaflasa'] = 'prop_beer_stz',
        ['ruzovaflasa'] = 'prop_beer_stz',
        ['default'] = 'prop_beer_bottle',
    },    
    BottlePosition = {
        pos = vec3(0.03, 0.03, 0.02), -- You can edit the position of the bottle where you want
        rot = vec3(0.0, 0.0, -1.5)
    },
    SipsPerBottle = 4, -- 4 sips to finish a bottle, when you finish the bottle it is removed from your inventory
    ThirstPerSip = 50000, -- +50000 thirst per sip, put whatever you want
    
    Effects = {
        levels = {
            { 
                bottle = 1, -- Effects after 1 bottle, 4 sips
                label = "effects.level1",
                walk = "move_m@drunk@slightlydrunk"
            },
            { 
                bottle = 2, -- Effects after 2 bottles, 8 sips
                label = "effects.level2",
                walk = "move_m@drunk@moderatedrunk"
                },
            { 
                bottle = 3, -- Effects after 3 bottles, 12 sips
                label = "effects.level3",
                walk = "move_m@drunk@verydrunk",
                knockout = {
                    chance = 0.5, -- 50% chance to pass out after the third bottle during 30sec
                    duration = 30000
                }
            }
        },
        screenEffect = {
            minBottles = 2, -- Screen effects after 2 bottles
            name = "DrugsMichaelAliensFight"
        },
        reduction = {
            rate = 0.1, 
            time = 120000 -- 0.1 alcohol reduction every 2min
        },
        Hangover = {
            walk = "move_m@drunk@verydrunk",
            stumbleChance = 0.8,
            stumbleInterval = 15000, -- 80% chance to stumble every 15sec
            duration = 60000,
            vehicleProtection = true -- To remove stumble while driving
        }
    },
    DrunkDriving = {
        enabled = true,
        minBottles = 1, -- Effects from 1 bottle
        controls = {
            accelerate = 32, -- Z (20 for QWERTY)
            brake = 33, -- S (21 for QWERTY)
            handbrake = 73, -- SPACE
            left = 34, -- Q (44 for QWERTY)
            right = 35, -- D (45 for QWERTY)
        },
        effects = {
            [1] = { -- 1-2 bottles
                steeringBias = 0.7, 
                speedVariation = 0.2,
                brakeChance = 0.05,
                blurEffect = false,
                randomHonking = false
            },
            [2] = { -- 3-4 bottles
                steeringBias = 1.5,
                speedVariation = 0.4,
                brakeChance = 0.1,
                blurEffect = true,
                randomHonking = true
            },
            [3] = { -- 5+ bottles
                steeringBias = 2.5,
                speedVariation = 0.6,
                brakeChance = 0.15,
                blurEffect = true,
                randomHonking = true
            }
    }
}
}