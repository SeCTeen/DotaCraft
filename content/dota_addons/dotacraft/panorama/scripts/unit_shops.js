var Root = $.GetContextPanel()
var Shops = {}
var LocalPlayerID = Game.GetLocalPlayerID()
var shop_state = "on"

// create shop
function Create_Shop(args){	
	
	// create the primary container
	var Container = $.CreatePanel("Panel", Root, args.Index)
	Container.AddClass("Container")	
	//Container.visible = false
	 
	// create all the items
	for(var orderIndex in args.Shop){
		var key = args.Shop[orderIndex].ItemName

		var shop_item = $.CreatePanel("Panel", Container, key)
		shop_item.BLoadLayout("file://{resources}/layout/custom_game/unit_shops_item.xml", false, false);
		shop_item.ItemName = key
		shop_item.ItemInfo = args.Shop[orderIndex]
		shop_item.Entity = args.Index
		shop_item.Race = args.Race
		shop_item.Tier = args.Tier
		shop_item.Order = orderIndex
		if(args.Tavern != null){
			shop_item.Tavern = args.Tavern
		}
	} 
	
	Shops[args.Index] = args.Shop.Items
	Container.visible = false
	$.Msg("Set Container Invisible ",Container)
	//Sort_Shop(Shops[args.Index], args.Index)
}

function Create_Single_Panel(args){
	var ShopUnit = args.Index
	var Shop = Root.FindChildTraverse(ShopUnit)
	var Hero = args.Hero
	var PlayerID = args.PlayerID
	
	//$.Msg(Shop)
	//$.Msg(Hero)
	$.Msg("Creating Hero Panel")
	if(Shop == null || Hero == null){
		$.Msg("Retuning, invalid params for individual item creation")
		return
	}
	
	// yeah I know I should really have a function to create items rather then copy pasta ;P
	var shop_item = $.CreatePanel("Panel", Shop, PlayerID+"_"+Hero)
	shop_item.BLoadLayout("file://{resources}/layout/custom_game/unit_shops_item.xml", false, false);
	shop_item.ItemName = args.Hero
	shop_item.ItemInfo = args.HeroInfo
	shop_item.Entity = args.Index
	shop_item.Hero = true
}

function Delete_Single_Panel(args){
	var Shop = args.Index
	var Hero = args.Hero
	var PlayerID = Game.GetLocalPlayerID()
	
	$.Msg(PlayerID)
	$.Msg(Hero)
	$.Msg(Shop)
	
	var Container = Root.FindChildTraverse(Shop)
	var HeroItemPanel = Container.FindChildTraverse(PlayerID+"_"+Hero)
	if(HeroItemPanel == null){
		HeroItemPanel = Container.FindChildTraverse(Hero)	
	}
	$.Msg(HeroItemPanel)
	HeroItemPanel.DeleteAsync(0.1)
}

function Current_Selected(){
	var PlayerID = Players.GetLocalPlayer();
	var mainSelected = Players.GetLocalPlayerPortraitUnit();
	 
	/*var Shop = Root.FindChildTraverse(mainSelected)
	if(Shop != null){
		ShowShop(mainSelected)
	}else{
		Hide_All_Shops()
	}
	
	$.Schedule(0.1, Current_Selected)*/
}

function Open_Shop(args) {
	var index = args.Shop
	ShowShop(index)
}

function ShowShop(entIndex){
	var PlayerID = Players.GetLocalPlayer();
	var Shop = Root.FindChildTraverse(entIndex)

	$.Msg("ShowShop ",entIndex," for Player "+PlayerID)

	if(Shop != null){
		$.Msg(" Shop ",entIndex," is now Visible")		
		Shop.visible = true
		shop_state = "on"
	}
}

function HideShop(entIndex){
	var PlayerID = Players.GetLocalPlayer();
	var Shop = Root.FindChildTraverse(entIndex)

	$.Msg("HideShop ",entIndex," for Player "+PlayerID)

	Shop.visible = false
	shop_state = "off"
}

function OnShopToggle() {
	var PlayerID = Players.GetLocalPlayer();
	var mainSelected = Players.GetLocalPlayerPortraitUnit();

	// If shop isn't open, try to open the shop closest to the main selected unit
	// If the shop panel is open, close it
	if (shop_state == "on")
	{
		Hide_All_Shops()
	}
	else
	{
		GameEvents.SendCustomGameEventToServer( "open_closest_shop", { "PlayerID" : LocalPlayerID, "UnitIndex" : mainSelected } );
	}

}

function Hide_All_Shops(){
	$.Msg("Hide_All_Shops")
	shop_state = "off"
	for(var key in Shops){
		var Shop = Root.FindChildTraverse(key)
		if(Shop.visible == true){
			$.Msg("Set Hidden Shop: ",key)
			Shop.visible = false
		}
	}
}

Game.AddCommand( "+ToggleShop", OnShopToggle, "", 0 );

function Delete_Shop_Content(args){
	var Shop = $("#"+args.Index)
	var PlayerID = args.PlayerID
	
	var bChildCount = Shop.GetChildCount()
	$.Msg("killing tavern")
	// loop and delete all the children
	for(i = 0; i < bChildCount; i++){
		var child = Shop.GetChild(i)
		$.Msg(child)
		if(child != null && child.id.indexOf(PlayerID.toString())){
			child.DeleteAsync(0.01)
		}
	}
}

(function () {
	GameEvents.Subscribe( "Shops_Create", Create_Shop);
	GameEvents.Subscribe( "Shops_Open", Open_Shop);
	GameEvents.Subscribe( "Shops_Create_Single_Panel", Create_Single_Panel);
	GameEvents.Subscribe( "Shops_Delete_Single_Panel", Delete_Single_Panel);
	GameEvents.Subscribe( "Shops_Remove_Content", Delete_Shop_Content);
	
})();