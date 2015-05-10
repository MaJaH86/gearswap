--[[     
 === Notes ===
    Souleater: By default, souleater will cancel after any weaponskill is used.  
               However, if Blood Weapon is used, Souleater will remain active for it's duration.
               It will be canceled after your next weaponskill, following Blood Weapon wearing off. 
               This behavior can be toggled off/on with @f9 (window key + f9) 
               Another option is to Nethervoid + Drain II and pop SE. It will stay up in this
               scenario as well.
    Last Resort: There is an LR Hybrid Mode toggle present. This is useful when Last Resort may be risky.
    
    I simplified this lua since I got Liberator. There is support for GS by using sets.engaged.GreatSword
    but you will have to edit the list in job_setup so that your GS is present.
    
    Set format is as follows: 
    sets.engaged.[CombatForm][CombatWeapon][Offense or DefenseMode][CustomGroup]
    CustomGroups = AM3
    
    TODO: Get STR/DEX Augment on Acro Legs.
    Make a new pair of boots + gloves with acc/atk 20 stp+5 str/dex+7
--]]
--
-- Initialization function for this job file.
function get_sets()
    mote_include_version = 2
    -- Load and initialize the include file.
    include('Mote-Include.lua')
end
 
 
-- Setup vars that are user-independent.
function job_setup()
    state.CapacityMode = M(false, 'Capacity Point Mantle')

    state.Buff.Souleater = buffactive.souleater or false
    state.Buff['Last Resort'] = buffactive['Last Resort'] or false
    -- Set the default to false if you'd rather SE always stay acitve
    state.SouleaterMode = M(true, 'Soul Eater Mode')
    
    wsList = S{'Spiral Hell', 'Insurgency'}
    gsList = S{'Tunglmyrkvi', 'Macbain', 'Kaquljaan', 'Mekosuchus Blade' }
    drk_sub_weapons = S{"Sangarius", "Usonmunku", "Perun"}

    get_combat_form()
    get_combat_weapon()
    update_melee_groups()
end
 
 
-- Setup vars that are user-dependent.  Can override this function in a sidecar file.
function user_setup()
    -- Options: Override default values
    state.OffenseMode:options('Normal', 'Mid', 'Acc')
    state.HybridMode:options('Normal', 'PDT')
    state.WeaponskillMode:options('Normal', 'Mid', 'Acc')
    state.CastingMode:options('Normal')
    state.IdleMode:options('Normal')
    state.RestingMode:options('Normal')
    state.PhysicalDefenseMode:options('PDT', 'Reraise')
    state.MagicalDefenseMode:options('MDT')
    
    war_sj = player.sub_job == 'WAR' or false
    
    -- Additional local binds
    send_command('bind != gs c toggle CapacityMode')
    send_command('bind @f9 gs c toggle SouleaterMode')
    send_command('bind ^` input /ja "Hasso" <me>')
    send_command('bind !` input /ja "Seigan" <me>')
    
    select_default_macro_book()
end
 
-- Called when this job file is unloaded (eg: job change)
function file_unload()
    send_command('unbind ^`')
    send_command('unbind !=')
    send_command('unbind ^[')
    send_command('unbind ![')
    send_command('unbind @f9')
end
 
       
-- Define sets and vars used by this job file.
function init_gear_sets()
     --------------------------------------
     -- Start defining the sets
     --------------------------------------
     -- Augmented gear
     Acro = {}
     Acro.Hands = {}
     Acro.Feet = {}
    
     Acro.Hands.Haste = {name="Acro gauntlets", augments={'STR+1 VIT+1','Accuracy+18 Attack+18','Haste+2'}} 
     Acro.Hands.STP = {name="Acro gauntlets", augments={'Accuracy+19 Attack+19','"Store TP"+5','Weapon skill damage +3%'}}

     Acro.Feet.STP = {name="Acro Leggings", augments={'DEX+4','Accuracy+17 Attack+17','"Store TP"+6'}} 
     Acro.Feet.WSD = {name="Acro Leggings", augments={'Accuracy+18 Attack+18','"Dbl. Atk."+3','Weapon skill damage +2%'}} 

     Niht = {}
     Niht.DarkMagic = {name="Niht Mantle", augments={'Attack+7','Dark magic skill +10','"Drain" and "Aspir" potency +25'}}
     Niht.WSD = {name="Niht Mantle", augments={'Attack+15','"Drain" and "Aspir" potency +10','Weapon skill damage +3%'}}

     -- Precast Sets
     -- Precast sets to enhance JAs
     sets.precast.JA['Diabolic Eye'] = {hands="Fallen's Finger Gauntlets +1"}
     sets.precast.JA['Arcane Circle'] = {feet="Ignominy Sollerets"}
     sets.precast.JA['Nether Void'] = {legs="Heathen's Flanchard"}
     sets.precast.JA['Dark Seal'] = {head="Fallen's burgeonet +1"}
     sets.precast.JA['Souleater'] = {head="Ignominy burgeonet +1"}
     --sets.precast.JA['Last Resort'] = {feet="Fallen's Sollerets +1"}
     sets.precast.JA['Blood Weapon'] = {body="Fallen's Cuirass +1"}
     sets.precast.JA['Weapon Bash'] = {hands="Ignominy Gauntlets +1"}

     sets.CapacityMantle  = { back="Mecistopins Mantle" }
     sets.Berserker       = { neck="Berserker's Torque" }
     sets.WSDayBonus      = { head="Gavialis Helm" }
     sets.WSBack          = { back="Trepidity Mantle" }
     sets.NightAmmo       = { ammo="Ginsen" }
     sets.DayAmmo         = { ammo="Tengu-No-Hane" }
     -- TP ears for night and day, AM3 up and down. 
     sets.LugraTripudio   = { ear1="Lugra Earring +1", ear2="Tripudio Earring" }
     sets.BrutalLugra     = { ear1="Brutal Earring", ear2="Lugra Earring +1" }
     sets.EnervateTripudio  = { ear1="Enervating Earring", ear2="Tripudio Earring" }
     sets.BrutalTrux      = { ear1="Brutal Earring", ear2="Trux Earring" }
     sets.Lugra           = { ear1="Lugra Earring +1" }
     -- Moonshade Substitute @ 3000 TP
     sets.Trux            = { ear2="Trux Earring" }
 
     sets.reive = {neck="Ygnas's Resolve +1"}
     -- Waltz set (chr and vit)
     sets.precast.Waltz = {
        head="Yaoyotl Helm",
    	body="Mes'yohi Haubergeon",
        legs="Cizin Breeches +1",
     }
            
     -- Fast cast sets for spells
     sets.precast.FC = {
        ammo="Impatiens",
        head="Fallen's Burgeonet +1",
        body="Yorium Cuirass",
        ear1="Loquacious Earring",
        hands="Yorium Gauntlets",
        ring2="Prolix Ring",
        legs="Limbo Trousers",
        feet="Yorium Sabatons"
     }

     sets.precast.FC.Utsusemi = set_combine(sets.precast.FC, { neck="Magoraga Beads" })

     sets.precast.FC['Elemental Magic'] = set_combine(sets.precast.FC, { 
         head="Cizin Helm +1",
         neck="Stoicheion Medal" 
     })
     sets.precast.FC['Enfeebling Magic'] = set_combine(sets.precast.FC, {
         head="Cizin Helm +1",
     })
     
     -- Midcast Sets
     sets.midcast.FastRecast = {
         ammo="Impatiens",
         head="Otomi Helm",
         hands="Cizin Mufflers +1",
         feet="Ejekamal Boots"
     }
            
     -- Specific spells
     sets.midcast.Utsusemi = {
         head="Otomi Helm",
         feet="Ejekamal Boots"
     }
 
     sets.midcast['Dark Magic'] = {
         head="Ignominy burgeonet +1", -- 17
         neck="Dark Torque", --7
         ear1="Lifestorm Earring",
         ear2="Psystorm Earring",
         body="Demon's Harness", --5
         hands="Fallen's Finger Gauntlets +1", -- 14
         waist="Casso Sash", -- 5
         ring1="Perception Ring",
         ring2="Sangoma Ring",
         back=Niht.Darkmagic,
         legs="Heathen's Flanchard", --18
         feet="Ignominy sollerets"
     }
     
	 sets.midcast['Enfeebling Magic'] = set_combine(sets.midcast['Dark Magic'], {
         neck="Eddy Necklace",
         head="Otomi Helm",
         body="Ignominy Cuirass +1",
         ring1="Globidonta Ring",
         back="Aput Mantle"
     })

     sets.midcast['Elemental Magic'] = {
         ammo="Impatiens",
         head="Ignominy burgeonet +1", -- int 20
         neck="Eddy Necklace", -- 11 matk
         ear1="Friomisi Earring", -- 10 matk
         ear2="Crematio Earring", -- 6 matk 6 mdmg
         body="Fallen's Cuirass +1", -- 15 matk
         hands="Fallen's Finger Gauntlets +1", -- 14 matk
         ring1="Shiva Ring", -- int 8
         ring2="Shiva Ring", -- matk 4
         waist="Caudata Belt", -- int 6
         --legs="Haruspex Slops",
         legs="Limbo Trousers", -- matk 17
         back="Aput Mantle", -- mdmg 10
         feet="Bale Sollerets +2" -- matk 8
     }
	 
     sets.midcast['Dread Spikes'] = set_combine(sets.midcast['Dark Magic'], {
         ammo="Impatiens",
         head="Gavialis Helm",
         body="Heathen's Cuirass +1",
         hands="Ignominy Gauntlets +1",
         ring1="Beeline Ring",
         ring2="K'ayres Ring",
         back="Trepidity Mantle",
         legs="Ignominy Flanchard +1",
         feet="Ejekamal Boots"
     })
     
     sets.midcast.Drain = set_combine(sets.midcast['Dark Magic'], {
         ear1="Gwati Earring",
         ear2="Hirudinea Earring",
         body="Lugra Cloak +1",
         ring2="Excelsis Ring",
     })

     sets.midcast.Aspir = sets.midcast.Drain

     sets.midcast.Absorb = set_combine(sets.midcast['Dark Magic'], {
         back="Chuparrosa Mantle",
         hands="Pavor Gauntlets",
         feet="Black Sollerets"
     })

     sets.midcast['Absorb-TP'] = set_combine(sets.midcast.Absorb, {
         hands="Heathen's Gauntlets +1"
     })
     sets.midcast['Absorb-STR'] = sets.midcast.Absorb
     sets.midcast['Absorb-DEX'] = sets.midcast.Absorb
     sets.midcast['Absorb-AGI'] = sets.midcast.Absorb
     sets.midcast['Absorb-INT'] = sets.midcast.Absorb
     sets.midcast['Absorb-MND'] = sets.midcast.Absorb
     sets.midcast['Absorb-VIT'] = sets.midcast.Absorb
     sets.midcast['Absorb-CHR'] = sets.midcast.Absorb
     sets.midcast['Absorb-Attri'] = sets.midcast.Absorb
     sets.midcast['Absorb-Acc'] = sets.midcast.Absorb

     -- Ranged for xbow
     sets.precast.RA = {
         head="Otomi Helm",
         hands="Buremte Gloves",
         feet="Ejekamal Boots"
     }
     sets.midcast.RA = {
         neck="Iqabi Necklace",
         ear2="Tripudio Earring",
         hands="Buremte Gloves",
         ring1="Beeline Ring",
         ring2="Garuda Ring",
         waist="Chaac Belt",
         legs="Aetosaur Trousers +1",
     }

     -- WEAPONSKILL SETS
     -- General sets
     sets.precast.WS = {
         ammo="Fracas Grenade",
         head="Otomi Helm",
         neck="Bale Choker",
         ear1="Brutal Earring",
         ear2="Moonshade Earring",
         body="Acro Surcoat",
         hands="Mikinaak Gauntlets",
         ring1="Karieyh Ring",
         ring2="Ifrit Ring +1",
         back=Niht.WSD,
         waist="Windbuffet Belt +1",
         legs="Yorium Cuisses",
         feet=Acro.Feet.WSD
     }
     sets.precast.WS.Mid = set_combine(sets.precast.WS, {
         ammo="Ginsen",
         head="Yaoyotl Helm",
         body="Mes'yohi Haubergeon",
         hands="Ignominy Gauntlets +1",
     })
     sets.precast.WS.Acc = set_combine(sets.precast.WS.Mid, {
         ear1="Zennaroi Earring",
         hands="Buremte Gloves",
         body="Fallen's Cuirass +1",
         waist="Olseni Belt",
     })
 
     -- RESOLUTION
     -- 86-100% STR
     sets.precast.WS.Resolution = set_combine(sets.precast.WS, {
         neck="Breeze Gorget",
         waist="Soil Belt"
     })
     sets.precast.WS.Resolution.Mid = set_combine(sets.precast.WS.Resolution, {
         ammo="Ginsen",
         head="Yaoyotl Helm",
     })
     sets.precast.WS.Resolution.Acc = set_combine(sets.precast.WS.Resolution.Mid, sets.precast.WS.Acc) 

     -- TORCLEAVER 
     -- VIT 80%
     sets.precast.WS.Torcleaver = set_combine(sets.precast.WS, {
         head="Fallen's burgeonet +1",
         neck="Aqua Gorget",
         hands="Crusher Gauntlets",
         legs="Yorium Cuisses",
         waist="Caudata Belt"
     })
     sets.precast.WS.Torcleaver.Mid = set_combine(sets.precast.WS.Mid, {
         ammo="Ginsen",
         neck="Aqua Gorget",
     })
     sets.precast.WS.Torcleaver.Acc = set_combine(sets.precast.WS.Torcleaver.Mid, sets.precast.WS.Acc)

     -- INSURGENCY
     -- 20% STR / 20% INT 
     sets.precast.WS.Insurgency = set_combine(sets.precast.WS, {
         ammo="Ginsen",
         head="Acro Helm",
         neck="Shadow Gorget",
         hands=Acro.Hands.STP,
         waist="Windbuffet Belt +1",
         legs="Yorium Cuisses",
     })
     sets.precast.WS.Insurgency.AM3 = set_combine(sets.precast.WS.Insurgency, {
     })
     sets.precast.WS.Insurgency.Mid = set_combine(sets.precast.WS.Insurgency, {
         head="Heathen's Burgonet +1",
         waist="Light Belt"
     })
     sets.precast.WS.Insurgency.AM3Mid = set_combine(sets.precast.WS.Insurgency.Mid, {})
     sets.precast.WS.Insurgency.Acc = set_combine(sets.precast.WS.Insurgency.Mid, {
         body="Fallen's Cuirass +1",
         ear1="Zennaroi Earring",
     })
     sets.precast.WS.Insurgency.AM3Acc = set_combine(sets.precast.WS.Insurgency.Acc, {})
     
     -- CROSS REAPER
     -- 60% STR / 60% MND
     sets.precast.WS['Cross Reaper'] = set_combine(sets.precast.WS, {
         head="Heathen's Burgonet +1",
         neck="Aqua Gorget",
         hands="Fallen's Finger Gauntlets +1",
         legs="Ignominy Flanchard +1",
         waist="Windbuffet Belt +1"
     })
     sets.precast.WS['Cross Reaper'].AM3 = set_combine(sets.precast.WS['Cross Reaper'], {})

     sets.precast.WS['Cross Reaper'].Mid = set_combine(sets.precast.WS['Cross Reaper'], {
         head="Heathen's Burgonet +1",
         hands=Acro.Hands.STP,
         waist="Metalsinger Belt",
         legs="Yorium Cuisses"
     })
     sets.precast.WS['Cross Reaper'].AM3Mid = set_combine(sets.precast.WS['Cross Reaper'].Mid, {
         waist="Windbuffet Belt +1",
     })
     sets.precast.WS['Cross Reaper'].Acc = set_combine(sets.precast.WS['Cross Reaper'].Mid, {
         ammo="Ginsen",
         neck="Defiant Collar",
         body="Fallen's Cuirass +1"
     })
     
     -- ENTROPY
     -- 86-100% INT 
     sets.precast.WS.Entropy = set_combine(sets.precast.WS, {
         ammo="Ginsen",
         head="Heathen's Burgonet +1",
         neck="Shadow Gorget",
         hands=Acro.Hands.STP,
         ring1="Shiva Ring",
         ring2="Shiva Ring",
         back="Toro Cape",
         waist="Soil Belt",
         legs="Yorium Cuisses"
     })
     sets.precast.WS.Entropy.AM3 = set_combine(sets.precast.WS.Entropy, {
         legs="Yorium Cuisses"
     })
     sets.precast.WS.Entropy.Mid = set_combine(sets.precast.WS.Entropy, { 
         legs="Yorium Cuisses"
     })
     sets.precast.WS.Entropy.AM3Mid = set_combine(sets.precast.WS.Entropy.Mid, {})
     sets.precast.WS.Entropy.Acc = set_combine(sets.precast.WS.Entropy.Mid, {})

     -- Quietus
     -- 60% STR / MND 
     sets.precast.WS.Quietus = set_combine(sets.precast.WS, {
         head="Heathen's Burgonet +1",
         neck="Shadow Gorget",
         ear2="Trux Earring",
         hands=Acro.Hands.STP,
         waist="Windbuffet Belt +1",
         legs="Yorium Cuisses",
     })
     sets.precast.WS.Quietus.AM3 = set_combine(sets.precast.WS.Quietus, {
         ear2="Bale Earring",
     })
     sets.precast.WS.Quietus.Mid = set_combine(sets.precast.WS.Quietus, {
         head="Yaoyotl Helm",
         waist="Caudata Belt",
     })
     sets.precast.WS.Quietus.AM3Mid = set_combine(sets.precast.WS.Quietus.Mid, {
         ear1="Bale Earring",
         ear2="Brutal Earring",
     })
     sets.precast.WS.Quietus.Acc = set_combine(sets.precast.WS.Quietus.Mid, sets.precast.WS.Acc)

     -- SPIRAL HELL
     -- 50% STR / 50% INT 
     sets.precast.WS['Spiral Hell'] = set_combine(sets.precast.WS['Entropy'], {
         head="Heathen's Burgonet +1",
         neck="Aqua Gorget",
         legs="Yorium Cuisses",
         waist="Metalsinger belt",
     })
     sets.precast.WS['Spiral Hell'].Mid = set_combine(sets.precast.WS['Spiral Hell'], sets.precast.WS.Mid)
     sets.precast.WS['Spiral Hell'].Acc = set_combine(sets.precast.WS['Spiral Hell'], sets.precast.WS.Acc)

     -- SHADOW OF DEATH
     -- 40% STR 40% INT - Darkness Elemental
     sets.precast.WS['Shadow of Death'] = set_combine(sets.precast.WS['Entropy'], {
         head="Ignominy burgeonet +1",
         neck="Aqua Gorget",
         body="Fallen's Cuirass +1",
         ear1="Friomisi Earring",
         hands="Fallen's Finger Gauntlets +1",
         back="Argochampsa Mantle",
         waist="Caudata Belt",
         feet="Ignominy Sollerets"
      })
     sets.precast.WS['Shadow of Death'].Mid = set_combine(sets.precast.WS['Shadow of Death'], sets.precast.WS.Mid)
     sets.precast.WS['Shadow of Death'].Acc = set_combine(sets.precast.WS['Shadow of Death'], sets.precast.WS.Acc)

     -- Sword WS's
     -- SANGUINE BLADE
     -- 50% MND / 50% STR Darkness Elemental
     sets.precast.WS['Sanguine Blade'] = set_combine(sets.precast.WS, {
         head="Ignominy burgeonet +1",
         neck="Stoicheion Medal",
         ear1="Friomisi Earring",
         body="Fallen's Cuirass +1",
         hands=Acro.Hands.STP,
         legs="Yorium Cuisses",
         ring2="Acumen Ring",
         back="Toro Cape",
         feet="Ignominy Sollerets"
     })
     sets.precast.WS['Sanguine Blade'].Mid = set_combine(sets.precast.WS['Sanguine Blade'], sets.precast.WS.Mid)
     sets.precast.WS['Sanguine Blade'].Acc = set_combine(sets.precast.WS['Sanguine Blade'], sets.precast.WS.Acc)

     -- REQUISCAT
     -- 73% MND - breath damage
     sets.precast.WS.Requiescat = set_combine(sets.precast.WS, {
         head="Ighwa Cap",
         neck="Shadow Gorget",
         hands="Umuthi Gloves",
         back="Bleating Mantle",
         waist="Soil Belt",
     })
     sets.precast.WS.Requiescat.Mid = set_combine(sets.precast.WS.Requiscat, sets.precast.WS.Mid)
     sets.precast.WS.Requiescat.Acc = set_combine(sets.precast.WS.Requiscat, sets.precast.WS.Acc)
     
     -- Resting sets
     sets.resting = {
         --head="Baghere Salade",
         body="Lugra Cloak +1",
         hands="Cizin Mufflers +1",
         ring1="Dark Ring",
         ring2="Paguroidea Ring",
         legs="Crimson Cuisses"
     }
 
     -- Idle sets
     sets.idle.Town = {
         ammo="Ginsen",
         --head="Heathen's Burgonet +1",
         neck="Ganesha's Mala",
         ear1="Lugra Earring +1",
         ear2="Tripudio Earring",
         body="Lugra Cloak +1",
         hands="Crusher Gauntlets",
         ring1="Karieyh Ring",
         ring2="Ifrit Ring +1",
         back=Niht.WSD,
         waist="Windbuffet Belt +1",
         legs="Crimson Cuisses",
         feet="Cizin Greaves +1"
     }
    sets.idle.Town.Adoulin = set_combine(sets.idle.Town, {
        body="Councilor's Garb"
    })
     
    sets.cool = set_combine(sets.idle.Town, {
         head="Otomi Helm",
         legs="Acro Breeches",
     })

     sets.idle.Field = set_combine(sets.idle.Town, {
         ammo="Ginsen",
         --head="Baghere Salade",
         neck="Coatl Gorget +1",
         body="Lugra Cloak +1",
         hands="Crusher Gauntlets",
         ring1="Karieyh Ring",
         ring2="Paguroidea Ring",
         back="Engulfer Cape +1",
         waist="Flume Belt",
         legs="Crimson Cuisses",
         feet="Cizin Greaves +1"
     })
     sets.idle.Regen = set_combine(sets.idle.Field, {
         body="Lugra Cloak +1",
     })
 
     sets.idle.Weak = {
         head="Twilight Helm",
         neck="Coatl Gorget +1",
         body="Twilight Mail",
         ring2="Paguroidea Ring",
         back="Repulse Mantle",
         waist="Flume Belt",
         legs="Crimson Cuisses",
         feet="Cizin Greaves +1"
     }

     sets.refresh = { 
         neck="Coatl Gorget +1",
         --body="Ares' Cuirass +1"
     }
     
     -- Defense sets
     sets.defense.PDT = {
         head="Ighwa Cap",
         neck="Agitator's Collar",
         body="Yorium Cuirass",
         hands="Crusher Gauntlets",
         ear1="Zennaroi Earring",
         ring1="Dark Ring",
         ring2="Patricius Ring",
         back="Repulse Mantle",
         waist="Flume Belt",
         legs="Cizin Breeches +1",
         feet="Cizin Greaves +1"
     }
     sets.defense.Reraise = sets.idle.Weak
 
     sets.defense.MDT = set_combine(sets.defense.PDT, {
         neck="Twilight Torque",
         ear1="Zennaroi Earring",
         ring2="K'ayres Ring",
         back="Engulfer Cape +1"
     })
 
     sets.Kiting = {legs="Crimson Cuisses"}
 
     sets.Reraise = {head="Twilight Helm",body="Twilight Mail"}

     sets.HighHaste = {
         ammo="Ginsen",
         hands=Acro.Hands.STP,
         feet=Acro.Feet.STP
     }
     
     -- Defensive sets to combine with various weapon-specific sets below
     -- These allow hybrid acc/pdt sets for difficult content
     sets.Defensive = {
         head="Ighwa Cap",
         neck="Agitator's Collar",
         body="Yorium Cuirass",
         hands="Crusher Gauntlets",
         ring2="Patricius Ring",
         back="Repulse Mantle",
         waist="Flume Belt",
         legs="Cizin Breeches +1",
         feet="Cizin Greaves +1"
     }
     sets.Defensive_Mid = {
         head="Ighwa Cap",
         neck="Agitator's Collar",
         body="Yorium Cuirass",
         hands="Crusher Gauntlets",
         back="Repulse Mantle",
         ring2="Patricius Ring",
     }
     sets.Defensive_Acc = {
         head="Ighwa Cap",
         neck="Agitator's Collar",
         hands="Crusher Gauntlets",
         body="Yorium Cuirass",
         ring2="Patricius Ring",
         legs="Cizin Breeches +1",
         feet="Cizin Greaves +1"
     }
 
     -- Engaged set, assumes Liberator
     sets.engaged = {
         ammo="Ginsen",
         head="Heathen's Burgonet +1",
         neck="Ganesha's Mala",
         ear1="Brutal Earring",
         ear2="Trux Earring",
    	 body="Acro Surcoat",
         hands=Acro.Hands.STP,
         ring1="Rajas Ring",
         ring2="K'ayres Ring",
         back="Bleating Mantle",
         waist="Windbuffet Belt +1",
         legs="Acro Breeches",
         feet="Ejekamal Boots"
     }
     sets.engaged.Mid = set_combine(sets.engaged, {
         ammo="Hasy Pinion +1",
         ear1="Bladeborn Earring",
         ear2="Steelflash Earring",
         feet=Acro.Feet.STP
     })
     sets.engaged.Acc = set_combine(sets.engaged.Mid, {
         head="Acro Helm",
         neck="Defiant Collar",
         ring2="Mars's Ring",
         waist="Olseni Belt"
     })
     -- Liberator AM3
     sets.engaged.AM3 = set_combine(sets.engaged, {
         head="Acro Helm",
         ear1="Enervating Earring",
         ear2="Tripudio Earring",
         body="Heathen's Cuirass +1",
         hands=Acro.Hands.Haste,
         feet=Acro.Feet.STP
     })
     sets.engaged.Mid.AM3 = set_combine(sets.engaged.AM3, {
         head="Heathen's Burgonet +1",
         body="Acro Surcoat",
         hands=Acro.Hands.Haste,
         feet=Acro.Feet.STP
     })
     sets.engaged.Acc.AM3 = set_combine(sets.engaged.Mid.AM3, {
         neck="Defiant Collar",
         ear1="Zennaroi Earring",
         ear2="Tripudio Earring",
         waist="Olseni Belt",
     })

     sets.engaged.PDT = set_combine(sets.engaged, sets.Defensive)
     sets.engaged.Mid.PDT = set_combine(sets.engaged.Mid, sets.Defensive_Mid)
     sets.engaged.Acc.PDT = set_combine(sets.engaged.Acc, sets.Defensive_Acc)

     --sets.engaged.DW = set_combine(sets.engaged, {
     --   head="Otomi Helm",
     --   ear1="Dudgeon Earring",
     --   ear2="Heartseeker Earring",
     --   waist="Patentia Sash"
     --})
     --sets.engaged.OneHand = set_combine(sets.engaged, {
     --    head="Yaoyotl Helm",
     --    ring2="Mars's Ring",
     --    feet=Acro.Feet.STP
     --})

     sets.engaged.GreatSword = set_combine(sets.engaged, {
         head="Otomi Helm",
         ear1="Brutal Earring",
         ear2="Tripudio Earring"
     })
     sets.engaged.GreatSword.Mid = set_combine(sets.engaged.Mid, {
         --back="Grounded Mantle +1"
         --ring2="K'ayres RIng"
     })
     sets.engaged.GreatSword.Acc = set_combine(sets.engaged.Acc, {
         hands="Heathen's Gauntlets +1"
     })

     sets.engaged.Reraise = set_combine(sets.engaged, {
     	head="Twilight Helm",neck="Twilight Torque",
     	body="Twilight Mail"
     })
    
     sets.buff.Souleater = { 
         head="Ignominy Burgeonet +1"
     }

     sets.buff['Last Resort'] = { 
         feet="Fallen's Sollerets +1" 
     }
end

-- Set eventArgs.handled to true if we don't want any automatic gear equipping to be done.
-- Set eventArgs.useMidcastGear to true if we want midcast gear equipped on precast.
function job_precast(spell, action, spellMap, eventArgs)
    aw_custom_aftermath_timers_precast(spell)
    --if spell.action_type == 'Magic' then
    --    equip(sets.precast.FC)
    --end
end
 
function job_post_precast(spell, action, spellMap, eventArgs)
    -- Make sure abilities using head gear don't swap 
	if spell.type:lower() == 'weaponskill' then
        -- handle Gavialis Helm
        if is_sc_element_today(spell) then
            if state.OffenseMode.current == 'Normal' and wsList:contains(spell.english) then
                -- do nothing
            else
                equip(sets.WSDayBonus)
            end
        end
        -- CP mantle must be worn when a mob dies, so make sure it's equipped for WS.
        if state.CapacityMode.value then
            equip(sets.CapacityMantle)
        end
        -- Use Lugra+1 from dusk to dawn
        if world.time >= (17*60) or world.time <= (7*60) then
            -- don't want moonshade @ 3000 TP
            if player.tp > 2999 then
                equip(sets.BrutalLugra)
            else -- use Lugra + moonshade
                equip(sets.Lugra)
            end
        else -- it's day time, use trux instead of moonshade
            if player.tp > 2999 then
                equip(sets.Trux)
            end
        end
        -- Use SOA neck piece for WS in rieves
        if buffactive['Reive Mark'] then
            equip(sets.reive)
        end
        -- Use Tengu-No-Hane for WS during the day, when acc mode is toggled
        if state.OffenseMode.current == 'Acc' then
            equip(select_ammo())
        end
        -- Trepidity Mantle rule: if your Niht Mantle augs suck, uncomment below
        --if world.day_element == 'Dark' then
        --    equip(sets.WSBack)
        --end
    end
end
 
-- Set eventArgs.handled to true if we don't want any automatic gear equipping to be done.
function job_midcast(spell, action, spellMap, eventArgs)
end
 
-- Run after the default midcast() is done.
-- eventArgs is the same one used in job_midcast, in case information needs to be persisted.
function job_post_midcast(spell, action, spellMap, eventArgs)
    if (state.HybridMode.current == 'PDT' and state.PhysicalDefenseMode.current == 'Reraise') then
        equip(sets.Reraise)
    end
end
 
-- Set eventArgs.handled to true if we don't want any automatic gear equipping to be done.
function job_aftercast(spell, action, spellMap, eventArgs)
    aw_custom_aftermath_timers_aftercast(spell)
    if state.Buff[spell.english] ~= nil then
        state.Buff[spell.english] = not spell.interrupted or buffactive[spell.english]
    end
end

function job_post_aftercast(spell, action, spellMap, eventArgs)
    if spell.type == 'WeaponSkill' then
        if state.Buff.Souleater and state.SouleaterMode.value then
            send_command('@wait 1.0;cancel souleater')
        end
    end
end
-------------------------------------------------------------------------------------------------------------------
-- Customization hooks for idle and melee sets, after they've been automatically constructed.
-------------------------------------------------------------------------------------------------------------------
-- Called before the Include starts constructing melee/idle/resting sets.
-- Can customize state or custom melee class values at this point.
-- Set eventArgs.handled to true if we don't want any automatic gear equipping to be done.
function job_handle_equipping_gear(status, eventArgs)
end
-- Modify the default idle set after it was constructed.
function customize_idle_set(idleSet)
    if player.mpp < 50 then
        idleSet = set_combine(idleSet, sets.refresh)
    end
    if player.hpp < 90 then
        idleSet = set_combine(idleSet, sets.idle.Regen)
    end
    if state.HybridMode.current == 'PDT' then
        idleSet = set_combine(idleSet, sets.defense.PDT)
    end
    return idleSet
end
 
-- Modify the default melee set after it was constructed.
function customize_melee_set(meleeSet)
    if state.CapacityMode.value then
        meleeSet = set_combine(meleeSet, sets.CapacityMantle)
    end
    if state.Buff['Last Resort'] and state.HybridMode.current == 'PDT' then
    	meleeSet = set_combine(meleeSet, sets.buff['Last Resort'])
    end
    if state.OffenseMode.current == 'Acc' then
        meleeSet = set_combine(meleeSet, select_ammo())
    end
    if state.CombatForm.has_value then
        meleeSet = set_combine(meleeSet, sets.HighHaste)
    end
    meleeSet = set_combine(meleeSet, select_earring())
    return meleeSet
end
 
-------------------------------------------------------------------------------------------------------------------
-- General hooks for other events.
-------------------------------------------------------------------------------------------------------------------
 
-- Called when the player's status changes.
function job_status_change(newStatus, oldStatus, eventArgs)
    if newStatus == "Engaged" then
        if buffactive['Last Resort'] and state.HybridMode.current == 'PDT' then
            equip(sets.buff['Last Resort'])
        end
        get_combat_weapon()
    elseif newStatus == 'Idle' then
        determine_idle_group()
    end
end
 
-- Called when a player gains or loses a buff.
-- buff == buff gained or lost
-- gain == true if the buff was gained, false if it was lost.
function job_buff_change(buff, gain)
    
    if state.Buff[buff] ~= nil then
        handle_equipping_gear(player.status)
    end
    
    if S{'haste', 'march', 'embrava', 'geo-haste', 'indi-haste'}:contains(buff:lower()) and gain then
        if buffactive['Last Resort'] then
            state.CombatForm:set("Haste")
            if not midaction() then
                handle_equipping_gear(player.status)
            end
        else
            state.CombatForm:reset()
            if not midaction() then
                handle_equipping_gear(player.status)
            end
        end
    end
    -- Drain II HP Boost. Set SE to stay on.
    if buff == "Max HP Boost" then
        if gain or buffactive['Max HP Boost'] then
            state.SouleaterMode:set(false)
        else
            state.SouleaterMode:set(true)
        end
    end
    -- Make sure SE stays on for BW
    if buff == 'Blood Weapon' then
        if gain or buffactive['Blood Weapon'] then
            state.SouleaterMode:set(false)
        else
            state.SouleaterMode:set(true)
        end
    end
    -- AM3 custom group
    if buff == 'Aftermath: Lv.3' then
        classes.CustomMeleeGroups:clear()
	
        if (buff == "Aftermath: Lv.3" and gain) or buffactive['Aftermath: Lv.3'] then
            classes.CustomMeleeGroups:append('AM3')
        end

        if not midaction() then
            handle_equipping_gear(player.status)
        end
    end
    -- Automatically wake me when I'm slept
    --if string.lower(buff) == "sleep" and gain and player.hp > 200 then
    --    equip(sets.Berserker)
    --end

    -- Warp ring rule, for any buff being lost
    if S{'Warp', 'Vocation'}:contains(player.equipment.ring2) then
        if not buffactive['Dedication'] then
            disable('ring2')
        end
    else
        enable('ring2')
    end

    if buff == "Souleater" then
        if gain then
            equip(sets.buff.Souleater)
            disable('head')
        else
            enable('head')
            if not midaction() then
                handle_equipping_gear(player.status)
            end
        end
    end
end
 
 
-------------------------------------------------------------------------------------------------------------------
-- User code that supplements self-commands.
-------------------------------------------------------------------------------------------------------------------
 
-- Called by the 'update' self-command, for common needs.
-- Set eventArgs.handled to true if we don't want automatic equipping of gear.
function job_update(cmdParams, eventArgs)
    
    war_sj = player.sub_job == 'WAR' or false
    get_combat_form()
    get_combat_weapon()
    update_melee_groups()

end

function get_custom_wsmode(spell, spellMap, default_wsmode)
    if state.OffenseMode.current == 'Mid' then
        if buffactive['Aftermath: Lv.3'] then
            return 'AM3Mid'
        end
    elseif state.OffenseMode.current == 'Acc' then
        if buffactive['Aftermath: Lv.3'] then
            return 'AM3Acc'
        end
    else
        if buffactive['Aftermath: Lv.3'] then
            return 'AM3'
        end
    end
end
-------------------------------------------------------------------------------------------------------------------
-- Utility functions specific to this job.
-------------------------------------------------------------------------------------------------------------------
function get_combat_form()
    --if war_sj then
        --state.CombatForm:set("War")
    --else
        --state.CombatForm:reset()
    --end
    --if S{'NIN', 'DNC'}:contains(player.sub_job) and drk_sub_weapons:contains(player.equipment.sub) then
    --    state.CombatForm:set("DW")
    --elseif S{'SAM', 'WAR'}:contains(player.sub_job) and player.equipment.sub == 'Rinda Shield' then
    --    state.CombatForm:set("OneHand")
    --else
    --    state.CombatForm:reset()
    --end

    if (buffactive['Last Resort']) then
        if (buffactive.embrava or buffactive.haste) and buffactive.march  then
            add_to_chat(8, '-------------Delay Capped-------------')
            state.CombatForm:set("Haste")
        else
            state.CombatForm:reset()
        end
    end
end

function get_combat_weapon()
    if gsList:contains(player.equipment.main) then
        state.CombatWeapon:set("GreatSword")
    else -- use regular set
        state.CombatWeapon:reset()
    end
end

function aw_custom_aftermath_timers_precast(spell)
    if spell.type == 'WeaponSkill' then
        info.aftermath = {}
        
        local mythic_ws = "Insurgency"
        
        info.aftermath.weaponskill = mythic_ws
        info.aftermath.duration = 0
        
        info.aftermath.level = math.floor(player.tp / 1000)
        if info.aftermath.level == 0 then
            info.aftermath.level = 1
        end
        
        if spell.english == mythic_ws and player.equipment.main == 'Liberator' then
            -- nothing can overwrite lvl 3
            if buffactive['Aftermath: Lv.3'] then
                return
            end
            -- only lvl 3 can overwrite lvl 2
            if info.aftermath.level ~= 3 and buffactive['Aftermath: Lv.2'] then
                return
            end
            
            if info.aftermath.level == 1 then
                info.aftermath.duration = 90
            elseif info.aftermath.level == 2 then
                info.aftermath.duration = 120
            else
                info.aftermath.duration = 180
            end
        end
    end
end

-- Call from job_aftercast() to create the custom aftermath timer.
function aw_custom_aftermath_timers_aftercast(spell)
    if not spell.interrupted and spell.type == 'WeaponSkill' and
       info.aftermath and info.aftermath.weaponskill == spell.english and info.aftermath.duration > 0 then

        local aftermath_name = 'Aftermath: Lv.'..tostring(info.aftermath.level)
        send_command('timers d "Aftermath: Lv.1"')
        send_command('timers d "Aftermath: Lv.2"')
        send_command('timers d "Aftermath: Lv.3"')
        send_command('timers c "'..aftermath_name..'" '..tostring(info.aftermath.duration)..' down abilities/aftermath'..tostring(info.aftermath.level)..'.png')

        info.aftermath = {}
    end
end

-- Handle notifications of general user state change.
function job_state_change(stateField, newValue, oldValue)
    --if stateField == 'Look Cool' then
    --    if newValue == 'On' then
    --        send_command('gs equip sets.cool;wait 1.2;input /lockstyle on;wait 1.2;gs c update user')
    --        --send_command('wait 1.2;gs c update user')
    --    else
    --        send_command('@input /lockstyle off')
    --    end
    --end
end

--windower.register_event('Zone change', function(new,old)
--    if state.LookCool.value == 'On' then
--        send_command('wait 3; gs equip sets.cool;wait 1.2;input /lockstyle on;wait 1.2;gs c update user')
--    end
--end)

function select_ammo()
    if world.time >= (18*60) or world.time <= (6*60) then
        return sets.NightAmmo
    else
        return sets.DayAmmo
    end
end

function select_earring()
    -- world.time is given in minutes into each day
    -- 7:00 AM would be 420 minutes
    -- 17:00 PM would be 1020 minutes
    if world.time >= (17*60) or world.time <= (7*60) then
        if classes.CustomMeleeGroups:contains('AM3') then
            --return sets.LugraTripudio
             return sets.EnervateTripudio
        else
            return sets.BrutalLugra
        end
    else
        if classes.CustomMeleeGroups:contains('AM3') then
             return sets.EnervateTripudio
        else
             return sets.BrutalTrux
        end
    end
end

-- Handle zone specific rules
windower.register_event('Zone change', function(new,old)
    determine_idle_group()
end)

function determine_idle_group()
    classes.CustomIdleGroups:clear()
    if areas.Adoulin:contains(world.area) then
    	classes.CustomIdleGroups:append('Adoulin')
    end
end

--function adjust_melee_groups()
--	classes.CustomMeleeGroups:clear()
--	if state.Buff.Aftermath then
--		classes.CustomMeleeGroups:append('AM')
--	end
--end
function update_melee_groups()

	classes.CustomMeleeGroups:clear()
	
    if buffactive['Aftermath: Lv.3'] then
		classes.CustomMeleeGroups:append('AM3')
	end
end

function select_default_macro_book()
    -- Default macro set/book
	if player.sub_job == 'DNC' then
		set_macro_page(6, 2)
	elseif player.sub_job == 'SAM' then
		set_macro_page(7, 4)
	else
		set_macro_page(8, 4)
	end
end
