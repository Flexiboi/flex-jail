local Translations = {
    error = {
        citizennothere = 'Burger niet aanwezig..',
        tofaraway = 'Je staat te ver weg..',
        alreadyrequestedjp = 'Je hebt al een aanvraag gedaan..',
        notenoughtjailpoints = 'Niet genoeg gevangenispunten..',
        requestdenied = 'Aanvraag geweigerd..',
        removejp = 'Er gingen %{value} gevangenispunten af',
        missingitem = 'Je mist %{value} x %{value2}',
        notworthy = 'Weet je wel hoe dit moet?',
        cantpaycorruptnpc = 'Ik verwacht wel €%{value} hier voor hoor..',
        canceled = "Gestopped",
        error404 = 'ERROR 404',
        allergy = 'Je bent hier allergisch aan..'
    },
    success = {
        reducedtime = 'Er ging een maandje van je tijd af!',
        earnedjp = 'Je verdiende %{value} gevangenispunten',
        boughtitem = "Je kocht %{value}(s) voor €%{value2}",
        requestedjp = 'Je aanvraag is ingediend',
        requestaccepted = 'Aanvraag is geaccepteerd!',
        payedcorruptnpc = 'Je betaalde €%{value} aan de agent',
    },
    info = {
        citizinotonline = 'Burger niet in de stad..',
        timeinjail = 'Je moet nog %{value} maand(en) in het gevang zitten',
        grabyourstuff = 'Ga je spullen halen voor je weg gaat!',
        newinmate = 'Nieuwe gevangene aangekomen!',
        youdidntseeanything = 'Je hebt niets gezien!',
        notrightnow = 'Nu even niet..',
        outside = {
            yes = '%{value} (%{value2}) mag nu niet meer naar buiten',
            no = '%{value} (%{value2}) mag nu naar buiten',
        },
        drawtext2d = {
            placesecretstash = "[E] Plaatsen \n [BACKSPACE] annuleren",
        },
        escapejail = {
            yes = 'Snel voor het te laat is!',
            no = 'Zou het nu best niet proberen..',
        },
        areyouinjail = 'Kom je wel net uit het gevang?',
        jailpoints = 'Je hebt %{value} gevangenispunten',
        job = {
            startwork = 'Gestart met werken',
            stopwork = 'Gestopt met werken',
            washing = {
                washtime = 'Nog %{value} seconden te gaan',
                howto = 'Neem kleding uit de bak. Steek het in de wasmachine. Haal het er uit. En leg het mooi in de kast!',
            },
            cleaning = {
                howto = 'Ga naar het vuil met de markering (Of kijk op je gps) en kuis het op!',
            },
            mining = {
                howto = 'Pak je axe. Ga naar je toegewezen steen (Kijk op je GPS). Hak hem in stukken. Neem je stuk mee naar de machine om het in stukken te boren. Leg het op de hoop met bakstenen.',
            },
            wood = {
                howto = 'Neem je hout uit het schap en snij het in stukken. Ga met de planken spullen maken en lever ze in!',
            },
        },
        getmoneybalance = 'Je hebt €%{value} ter beschikking!',
        airdefence = {
            goaway = 'Je gaat het beperkte luchtruim binnen! Ga alsjeblieft in de volgende %{value} seconden weg!',
            alarmactivated = 'Luchtafweersystemen zijn geactiveerd! Ga hier weg!',
        }
    },
    menu = {
        back = 'Terug',
        yes = 'Ja',
        no = 'Nee',
        drawer = {
            label = 'Lade',
            desc = 'Nummer',
        },
        evd_drawer_h = 'Bewijslade DOC',
        evd_drawer_b = 'U krijgt toegang tot de lade door een bewijsnummer in te voeren',
        evd_stash_h = 'Algemeen bewijsmateriaal DOC',
        evd_stash_b = 'De voorraad bewijs die u in het algemeen kunt gebruiken',
        current_evidence_doc = 'DOC Stash #%{value} | Lade #%{value2}',
        general_current_evidence_doc = 'Algemeen bewijsmateriaal DOC | #%{value}',
        paycheck = 'Vraag om je loon..',
        jailtime = {
            title = 'Gevangenistijd',
            desc = 'Vraag Hoe lang je nog moet zitten',
        },
        storage = {
            title = 'Opslag',
            desc = 'Hoeveehleid: %{value}',
        },
        checkmoney = {
            title = 'Heb ik al een miljoen?',
            desc = 'Bekijk hoeveel geld je op je bank hebt staan',
        },
        playersinjail = {
            title1 = 'Burgers in het gevang',
            manageinmate = '%{value} (%{value2}) Beheren',
            timeinjail = 'Nog %{value} maanden te gaan',
            lifetimeinjail = 'Nog levenslang te gaan',
            checkjailpoints = {
                title = 'Gevangenispunten',
                desc = '%{value} heeft %{value2} gevangenispunten',
            },
            cangooutside = {
                title = 'Mag de gevangene uit naar buiten?',
                desc = 'Huidige status: %{value} (Druk om aan te passen)',
            },
            removefromsystem = {
                title = 'Verwijder de gevangene uit je systeem..',
                desc = 'Dit kan alleen als hij/zij 0 maanden over heeft en ontsnapt is!',
            },
            release = {
                title = '%{value} (%{value2}) mag vrij gelaten worden',
                yes = 'Ik ga hem halen',
                no = 'Laat hem maar vrij',
            }
        },
        camera = {
            title = 'Bekijk gevangeniscameras',
            desc = 'Zie wat de gevangenen aan het doen zijn',
        },
        mainjailmenu = 'gevangenismenu',
        jailpointsrequests = {
            title = 'Aanvragen',
            desc = 'Bekijk hier alle aanvragen van de gevangenen',
            sub = {
                title = 'Aanvraag van %{value} (%{value2})',
            }
        },
        shop = {
            curency = '€',
            amount = {
                title = 'Hoevel van %{value} wil je er?',
                desc = 'Getal',
            },
            mainmenu = 'Wat wil je doen?',
            buy = 'Koop %{value} voor %{value2}%{value3}',
            stock = 'Huidige stock: %{value}',
            food = {
                title = 'Bestel eten',
                desc = "Hier kan je al wat lekkers vinden!",
            },
            pointshop = {
                title = 'Ben je braaf geweest?',
                desc = "Besteed hier al je gevangenispunten!",
            },
            illegal = {
                title = 'Wat moet je?',
                desc = "Zou je dit wel doen?",
            },
        },
    },
    progress = {
        job = {
            mining = {
                mine = 'Steen hakken..',
                drilling = 'Aan het boren..',
            },
            cleaning = {
                clean = 'Schoon maken..',
            },
            wood = {
                saw = 'Zagen..',
            },
        },
        crack = {
            bake = 'Bakken..',
        },
        eatdrink = {
            eating = 'Smullen maar..',
            drinking = 'Slurpen..',
            smoking = 'Aan het smoren..',
            drugs = 'Aan het snuiven..',
            pill = 'Pilletje slikken..'
        },
    },
    target = {
        armory = 'Wapenkluis',
        evidence = 'Bewijskast',
        storage = 'Opslag',
        release = 'Mag ik al naar buiten?',
        paycorruptdoc = 'Praten..',
        hack = 'Hacken..',
        rope = 'Touw gooien..',
        climb = 'Klimmen..',
        istherehighsecurity = 'Is er hoge beveiliging?',
        secretstash = {
            open = 'Openen',
            seize = 'Neem in beslag',
            move = 'Verplaats opslag',
        },
        retreiveitems = 'Vraag je spullen terug',
        calldoc = 'Melding naar DOC',
        job = {
            howto = 'Wat moet ik doen?',
            startwork = 'Start met werken',
            stopwork = 'Stop met werken',
            washing = {
                take = 'Neem kleren',
                startwash = 'Start wassen',
                stopwash = 'Neem uit wasmachine',
                store = 'Berg kleren op',
            },
            mining = {
                mine = 'Hak steen',
                drilling = 'Boren',
                dropoff = 'Lever stenen in',
            },
            cleaning = {
                clean = 'Maak schoon',
            },
            wood = {
                sell = 'Verkoop je werken',
                takewood = 'Neem houtblok',
                sawing = 'In stukken zagen',
            },
        },
        cantine = {
            shop = 'Bestellen',
        },
        crack = {
            placepot = 'Plaats pot',
            bake = 'Maak klaar',
            take = 'Pak op',
        },
    },
    cctv = {
        left = 'Links',
        right = 'Rechts',
        up = 'Op',
        down = 'Neer',
        esc = 'Sluiten',
    },
    alert = {
        jailbreak = {
            title = 'Ontsnapping',
            code = '11-11',
            message = 'Burger gespot die aan het uitbreken is',
        },
        breakout = {
            title = 'Ontsnapping',
            code = '11-12',
            message = 'Burger gespot die iemand aan het bevrijden is',
        },
        noteleport = 'DOC komt je zo halen',
    },
    commands = {
        id = 'Geluksnummer',
        time = 'Tijd (In minuten)',
        jail = 'Stuur naar gevangenis',
        unjail = 'Zet uit gevangenis',
        jailtime = 'Bekijk hoe lang je nog in het gevang zit',
        jailpoints = 'Bekijk je gevangenis punten',
        points = {
            amount = 'Hoeveelheid',
            add = 'Voeg jailpounten toe',
            remove = 'Verwijder',
        },
        fixjaildata = 'Fix een gevangene zijn data',
    },
}

Lang = Locale:new({
    phrases = Translations,
    warnOnMissing = true
})
