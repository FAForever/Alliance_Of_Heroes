local ModPath = '/mods/Alliance_Of_Heroes/'

Skills = {
	{
		Name = 'Weapon Skill',
		FocusSkill = 'Puissance',
		IsAvailable = import(ModPath..'Modules/Skills/WeaponSkill.lua').IsAvailable,
	},
	{
		Name = 'Weapon Mastery',
		FocusSkill = 'Dexterity',
		IsAvailable = import(ModPath..'Modules/Skills/WeaponMastery.lua').IsAvailable,
	},
	{
		Name = 'Light Armor Mastery',
		FocusSkill = 'Dexterity',
		IsAvailable = import(ModPath..'Modules/Skills/LightArmor.lua').IsAvailable,
		Description = import(ModPath..'Modules/Skills/LightArmor.lua').Description,
	},
	{
		Name = 'Medium Armor Mastery',
		FocusSkill = 'Puissance',
		IsAvailable = import(ModPath..'Modules/Skills/MediumArmor.lua').IsAvailable,
	},
	{
		Name = 'Heavy Armor Mastery',
		FocusSkill = 'Puissance',
		IsAvailable = import(ModPath..'Modules/Skills/HeavyArmor.lua').IsAvailable,
	},	
	{
		Name = 'Restoration',
		FocusSkill = 'Intelligence',
		IsAvailable = import(ModPath..'Modules/Skills/Restoration.lua').IsAvailable,
	},
	{
		Name = 'Building',
		FocusSkill = 'Intelligence',
		IsAvailable = import(ModPath..'Modules/Skills/Building.lua').IsAvailable,
	},
	{
		Name = 'Bardsong',
		FocusSkill = 'Intelligence',
		IsAvailable = import(ModPath..'Modules/Skills/Bardsong.lua').IsAvailable,
	},
	{
		Name = 'Rangercraft',
		FocusSkill = 'Dexterity',
		IsAvailable = import(ModPath..'Modules/Skills/Rangercraft.lua').IsAvailable,
	},
}