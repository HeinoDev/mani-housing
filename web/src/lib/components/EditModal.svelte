<script lang="ts">
    import { Houses, visibilityStore as visibility, Current } from "$lib/stores/VisibilityStore";
    import { fetchNui } from "$lib/utils/fetchNui";
    export let houseId: string;
    $: house = $Houses[houseId];
    import { createEventDispatcher } from 'svelte';
    const dispatch = createEventDispatcher();
    function CloseEditModal() {
        dispatch('close');
    }
    function HandleGaragePoint() {
        if (houseId) {
            fetchNui("SetGarage", parseInt(houseId) + 1);
            Current.set("guide")
        }
    }
    function HandleSellProperty() {
        dispatch('sell');
    }
    function HandleRemoveProperty() {
        dispatch('remove');
    }
</script>
<div class="fixed inset-0 flex items-center justify-center bg-black bg-opacity-50 select-none z-50">
    <div class="w-[500px] max-h-[80vh] bg-[#121212] rounded-md shadow-2xl flex flex-col border border-[#333333]">
        <header class="bg-[#1a1a1a] border-b border-[#333333] px-2 py-2 flex justify-between items-center flex-shrink-0">
            <div class="flex items-center">
                <h1 class="text-white font-medium text-sm">Edit Property</h1>
            </div>
            <div class="flex items-center gap-2">
                <button onclick={CloseEditModal} class="text-gray-400 hover:text-white">
                    <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><line x1="18" y1="6" x2="6" y2="18"></line><line x1="6" y1="6" x2="18" y2="18"></line></svg>
                </button>
            </div>
        </header>
        <div class="flex-1 flex flex-col overflow-hidden p-2">
            <div class="space-y-2 overflow-y-auto hide-scrollbar flex-1">
                {#if house}
                    <div class="bg-[#1a1a1a] rounded-lg p-2 border border-[#333333]">
                        <h3 class="text-white font-medium text-sm mb-1">{house.Coords.Zone}: {house.HouseId}</h3>
                        <p class="text-gray-400 text-xs">Shell: {house.Shell}</p>
                        {#if house.SalesData?.OwnerName}
                            <p class="text-gray-400 text-xs">Owner: {house.SalesData.OwnerName}</p>
                        {/if}
                    </div>
                    <div class="bg-[#1a1a1a] rounded-lg p-2 border border-[#333333]">
                        <h4 class="text-white font-medium text-sm mb-1">Sales Data</h4>
                        <div class="space-y-1 text-xs text-gray-400">
                            <div class="flex justify-between">
                                <span>Agent:</span>
                                <span>{house.SalesData?.Salesman || 'N/A'}</span>
                            </div>
                            <div class="flex justify-between">
                                <span>Salesman Job:</span>
                                <span>{house.SalesData?.SalesmanJobLabel || 'N/A'}</span>
                            </div>
                            <div class="flex justify-between">
                                <span>Price:</span>
                                <span>${house.SalesData?.Price?.toLocaleString() || '0'}</span>
                            </div>
                        </div>
                    </div>
                {:else}
                    <div class="text-center text-gray-400 py-4">House not found</div>
                {/if}
            </div>
            <div class="space-y-2 mt-2 flex-shrink-0">
                <button onclick={HandleGaragePoint} class="w-full bg-blue-400 text-white py-1 rounded-md text-xs font-medium hover:bg-blue-500 transition-colors" disabled={!house}>
                    {house?.Coords.Garage ? 'Update' : 'Add'} Garage Point
                </button>
                <button onclick={HandleSellProperty} class="w-full bg-green-600 text-white py-1 rounded-md text-xs font-medium hover:bg-green-800 transition-colors" disabled={!house}>
                    Sell Property
                </button>
                <button onclick={HandleRemoveProperty} class="w-full bg-red-400 text-white py-1 rounded-md text-xs font-medium hover:bg-red-500 transition-colors" disabled={!house}>
                    Remove Property
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