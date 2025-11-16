<script lang="ts">
    import { Houses } from "$lib/stores/VisibilityStore";
    import { fetchNui } from "$lib/utils/fetchNui";
    export let houseId: number;
    let house = $Houses[houseId.toString()];
    let showGarageModal = false; // If needed for garage sub-modal, but for now direct NUI

    function CloseEditModal() {
        dispatch('close');
    }

    function HandleGaragePoint() {
        fetchNui(house.Coords.Garage ? "UpdateGaragePoint" : "AddGaragePoint", { id: houseId });
        // Optionally refresh house data or close
    }

    function HandleSellProperty() {
        fetchNui("SellProperty", { id: houseId });
        CloseEditModal();
    }
</script>

<div class="fixed inset-0 flex items-center justify-center bg-black bg-opacity-50 select-none z-50">
    <div class="w-[500px] h-[450px] bg-[#121212] rounded-md shadow-2xl flex flex-col overflow-hidden border border-[#333333]">
        <header class="bg-[#1a1a1a] border-b border-[#333333] px-4 py-3 flex justify-between items-center">
            <div class="flex items-center">
                <h1 class="text-white font-medium">Edit Property</h1>
            </div>
            <div class="flex items-center gap-4">
                <button onclick={CloseEditModal} class="text-gray-400 hover:text-white">
                    <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><line x1="18" y1="6" x2="6" y2="18"></line><line x1="6" y1="6" x2="18" y2="18"></line></svg>
                </button>
            </div>
        </header>
        <div class="flex-1 p-4 space-y-4 overflow-y-auto hide-scrollbar">
            <div class="bg-[#1a1a1a] rounded-lg p-3 border border-[#333333]">
                <h3 class="text-white font-medium mb-2">{house.Coords.Zone}: {house.HouseId}</h3>
                {#if house.SalesData.OwnerName}
                    <p class="text-gray-400 text-sm">Owner: {house.SalesData.OwnerName}</p>
                {/if}
                <p class="text-gray-400 text-sm">Shell: {house.Shell}</p>                
            </div>
            <div class="bg-[#1a1a1a] rounded-lg p-3 border border-[#333333]">
                <h4 class="text-white font-medium mb-2">Sales Data</h4>
                <div class="space-y-1 text-xs text-gray-400">
                    <div class="flex justify-between">
                        <span>Salesman:</span>
                        <span>{house.SalesData.Salesman}</span>
                    </div>
                    <div class="flex justify-between">
                        <span>Salesman Job:</span>
                        <span>{house.SalesData.SalesmanJobLabel}</span>
                    </div>
                    <div class="flex justify-between">
                        <span>Price:</span>
                        <span>${house.SalesData.Price.toLocaleString()}</span>
                    </div>
                </div>
            </div>
            <div class="space-y-3">
                <button onclick={HandleGaragePoint} class="w-full bg-blue-400 text-white py-2 rounded-md text-sm font-medium hover:bg-blue-500 transition-colors">
                    {house.Coords.Garage ? 'Update' : 'Add'} Garage Point
                </button>
                <button onclick={HandleSellProperty} class="w-full bg-red-400 text-white py-2 rounded-md text-sm font-medium hover:bg-red-500 transition-colors">
                    Sell Property
                </button>
            </div>
        </div>
    </div>
</div>

<style>
    .hide-scrollbar::-webkit-scrollbar {
        display: none;
    }
   
    .hide-scrollbar {
        -ms-overflow-style: none;  /* IE and Edge */
        scrollbar-width: none;  /* Firefox */
    }
    * {
        user-select: none;
        -webkit-user-select: none;
        -moz-user-select: none;
        -ms-user-select: none;
    }
</style>