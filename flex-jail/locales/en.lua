local Translations = {
    error = {
        citizennothere = 'Citizen not present..',
        tofaraway = 'You are too far away..',
        alreadyrequestedjp = 'You already made a request..',
        notenoughtjailpoints = 'Not enough jail points..',
        requestdenied = 'Request denied..',
        removejp = '%{value} jail points were removed',
        missingitem = 'You are missing %{value} x %{value2}',
        notworthy = 'Do you even know how this works?',
        cantpaycorruptnpc = 'I expect €%{value} for this..',
        canceled = "Cancelled",
        error404 = 'ERROR 404',
        allergy = 'You are allergic to this..'
    },
    success = {
        reducedtime = 'A month was taken off your time!',
        earnedjp = 'You earned %{value} jail points',
        boughtitem = "You bought %{value}(s) for €%{value2}",
        requestedjp = 'Your request has been submitted',
        requestaccepted = 'Request has been accepted!',
        payedcorruptnpc = 'You paid €%{value} to the officer',
    },
    info = {
        citizinotonline = 'Citizen not in the city..',
        timeinjail = 'You still need to serve %{value} month(s) in jail',
        grabyourstuff = 'Grab your stuff before you leave!',
        newinmate = 'New inmate has arrived!',
        youdidntseeanything = 'You didn’t see anything!',
        notrightnow = 'Not right now..',
        outside = {
            yes = '%{value} (%{value2}) may no longer go outside',
            no = '%{value} (%{value2}) may now go outside',
        },
        drawtext2d = {
            placesecretstash = "[E] Place \n [BACKSPACE] cancel",
        },
        escapejail = {
            yes = 'Hurry before it’s too late!',
            no = 'Now is not the best time..',
        },
        areyouinjail = 'Did you just get out of jail?',
        jailpoints = 'You have %{value} jail points',
        job = {
            startwork = 'Started working',
            stopwork = 'Stopped working',
            washing = {
                washtime = '%{value} seconds remaining',
                howto = 'Take clothes from the bin. Put them in the washing machine. Take them out. Fold them neatly in the closet!',
            },
            cleaning = {
                howto = 'Go to the marked dirt (or check your GPS) and clean it!',
            },
            mining = {
                howto = 'Grab your axe. Go to your assigned rock (check GPS). Break it. Take a piece to the drill. Put it on the brick pile.',
            },
            wood = {
                howto = 'Take wood from the shelf and saw it into pieces. Craft items with the planks and turn them in!',
            },
        },
        getmoneybalance = 'You have €%{value} available!',
        airdefence = {
            goaway = 'You are entering restricted airspace! Please leave within %{value} seconds!',
            alarmactivated = 'Air defense systems activated! Leave this area!',
        }
    },
    menu = {
        back = 'Back',
        yes = 'Yes',
        no = 'No',
        drawer = {
            label = 'Drawer',
            desc = 'Number',
        },
        evd_drawer_h = 'DOC Evidence Drawer',
        evd_drawer_b = 'Access the drawer by entering an evidence number',
        evd_stash_h = 'General DOC Evidence',
        evd_stash_b = 'Stock of evidence available for general use',
        current_evidence_doc = 'DOC Stash #%{value} | Drawer #%{value2}',
        general_current_evidence_doc = 'General DOC Evidence | #%{value}',
        paycheck = 'Request your paycheck..',
        jailtime = {
            title = 'Jail Time',
            desc = 'Check how much time you have left',
        },
        storage = {
            title = 'Storage',
            desc = 'Quantity: %{value}',
        },
        checkmoney = {
            title = 'Do I have a million yet?',
            desc = 'See how much money you have in your bank',
        },
        playersinjail = {
            title1 = 'Citizens in jail',
            manageinmate = 'Manage %{value} (%{value2})',
            timeinjail = '%{value} months remaining',
            lifetimeinjail = 'Serving life sentence',
            checkjailpoints = {
                title = 'Jail Points',
                desc = '%{value} has %{value2} jail points',
            },
            cangooutside = {
                title = 'Can the inmate go outside?',
                desc = 'Current status: %{value} (Press to change)',
            },
            removefromsystem = {
                title = 'Remove inmate from the system..',
                desc = 'Only possible if they have 0 months left and have escaped!',
            },
            release = {
                title = '%{value} (%{value2}) can be released',
                yes = 'I’ll go get them',
                no = 'Let them go',
            }
        },
        camera = {
            title = 'View prison cameras',
            desc = 'See what the inmates are up to',
        },
        mainjailmenu = 'prison menu',
        jailpointsrequests = {
            title = 'Requests',
            desc = 'View all inmate requests here',
            sub = {
                title = 'Request from %{value} (%{value2})',
            }
        },
        shop = {
            curency = '€',
            amount = {
                title = 'How many of %{value} do you want?',
                desc = 'Number',
            },
            mainmenu = 'What do you want to do?',
            buy = 'Buy %{value} for %{value2}%{value3}',
            stock = 'Current stock: %{value}',
            food = {
                title = 'Order food',
                desc = "Find something tasty here!",
            },
            pointshop = {
                title = 'Been good lately?',
                desc = "Spend your jail points here!",
            },
            illegal = {
                title = 'What do you need?',
                desc = "Are you sure you want to do this?",
            },
        },
    },
    progress = {
        job = {
            mining = {
                mine = 'Mining rock..',
                drilling = 'Drilling..',
            },
            cleaning = {
                clean = 'Cleaning..',
            },
            wood = {
                saw = 'Sawing..',
            },
        },
        crack = {
            bake = 'Baking..',
        },
        eatdrink = {
            eating = 'Enjoying the meal..',
            drinking = 'Drinking..',
            smoking = 'Smoking..',
            drugs = 'Snorting..',
            pill = 'Taking a pill..'
        },
    },
    target = {
        armory = 'Weapon Vault',
        evidence = 'Evidence Cabinet',
        storage = 'Storage',
        release = 'Can I go outside now?',
        paycorruptdoc = 'Talk..',
        hack = 'Hack..',
        rope = 'Throw rope..',
        climb = 'Climb..',
        istherehighsecurity = 'Is there high security?',
        secretstash = {
            open = 'Open',
            seize = 'Seize',
            move = 'Move stash',
        },
        retreiveitems = 'Retrieve your belongings',
        calldoc = 'Notify DOC',
        job = {
            howto = 'What do I do?',
            startwork = 'Start working',
            stopwork = 'Stop working',
            washing = {
                take = 'Take clothes',
                startwash = 'Start washing',
                stopwash = 'Take out of washer',
                store = 'Store clothes',
            },
            mining = {
                mine = 'Mine rock',
                drilling = 'Drill',
                dropoff = 'Drop off rocks',
            },
            cleaning = {
                clean = 'Clean',
            },
            wood = {
                sell = 'Sell your work',
                takewood = 'Take wood block',
                sawing = 'Saw into pieces',
            },
        },
        cantine = {
            shop = 'Order',
        },
        crack = {
            placepot = 'Place pot',
            bake = 'Cook',
            take = 'Pick up',
        },
    },
    cctv = {
        left = 'Left',
        right = 'Right',
        up = 'Up',
        down = 'Down',
        esc = 'Close',
    },
    alert = {
        jailbreak = {
            title = 'Escape',
            code = '11-11',
            message = 'Citizen spotted breaking out',
        },
        breakout = {
            title = 'Escape',
            code = '11-12',
            message = 'Citizen spotted freeing someone',
        },
        noteleport = 'DOC will come get you shortly',
    },
    commands = {
        id = 'Lucky number',
        time = 'Time (in minutes)',
        jail = 'Send to jail',
        unjail = 'Release from jail',
        jailtime = 'Check how much jail time you have left',
        jailpoints = 'Check your jail points',
        points = {
            amount = 'Amount',
            add = 'Add jail points',
            remove = 'Remove',
        },
        fixjaildata = 'Fix a prisoner’s data',
    },
}

Lang = Locale:new({
    phrases = Translations,
    warnOnMissing = true
})
