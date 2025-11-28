<!-- CreateModal.svelte -->
<script lang="ts">
    import { Config, Locales } from "$lib/stores/VisibilityStore";
    import { createEventDispatcher } from 'svelte';
   
    const dispatch = createEventDispatcher();
   
    export let selectedShell = '';
    export let price = 0;
    export let includeGarage = false;
   
    function CloseCreateModal() {
        dispatch('close');
    }
   
    function HandleSubmit() {
        if (selectedShell && price > 0) {
            dispatch('submit', {
                shell: selectedShell,
                price: price,
                includeGarage: includeGarage
            });
        }
    }
</script>

<div class="fixed inset-0 flex items-center justify-center bg-black bg-opacity-50 select-none z-50">
    <div class="w-[500px] h-[400px] bg-[#121212] rounded-md shadow-2xl flex flex-col overflow-hidden border border-[#333333]">

        <header class="bg-[#1a1a1a] border-b border-[#333333] px-4 py-3 flex justify-between items-center">
            <div class="flex items-center">
                <h1 class="text-white font-medium">{$Locales["UI.CreateHouse"]}</h1>
            </div>
            <div class="flex items-center gap-4">
                <button on:click={CloseCreateModal} class="text-gray-400 hover:text-white">
                    <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><line x1="18" y1="6" x2="6" y2="18"></line><line x1="6" y1="6" x2="18" y2="18"></line></svg>
                </button>
            </div>
        </header>

        <div class="flex-1 p-6 overflow-y-auto">
            <div class="space-y-6">
                <div>
                    <label class="block text-gray-300 text-sm font-medium mb-2">{$Locales["UI.ChooseShell"]}</label>
                    <div class="relative">
                        <select bind:value={selectedShell} class="w-full bg-[#1e1e1e] border border-[#333333] rounded-md px-3 py-2 text-white text-sm focus:outline-none focus:ring-2 focus:ring-blue-400 appearance-none cursor-pointer">
                            {#each $Config.Shells as shell}
                                <option value={shell.Model}>{shell.Label}</option>
                            {/each}
                        </select>
                        <div class="absolute inset-y-0 right-0 flex items-center px-2 pointer-events-none">
                            <svg class="w-4 h-4 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 9l-7 7-7-7"></path>
                            </svg>
                        </div>
                    </div>
                </div>
                <div>
                    <label class="block text-gray-300 text-sm font-medium mb-2">{$Locales["UI.Price"]}</label>
                    <input type="number" bind:value={price} min="0" class="w-full bg-[#1e1e1e] border border-[#333333] rounded-md px-3 py-2 text-white text-sm focus:outline-none focus:ring-2 focus:ring-blue-400" placeholder="Enter price">
                </div>
                <div class="flex items-center space-x-3">
                    <div class="relative flex items-center">
                        <input type="checkbox" bind:checked={includeGarage} id="garage" class="sr-only peer">
                        <label for="garage" class="relative flex items-center cursor-pointer">
                            <div class="w-5 h-5 bg-[#1e1e1e] border-2 border-[#333333] rounded peer-checked:bg-blue-400 peer-focus:ring-2 peer-focus:ring-blue-400 transition-all duration-200 peer-checked:border-blue-400"></div>
                            <div class="absolute inset-0 w-5 h-5 flex items-center justify-center pointer-events-none">
                                {#if includeGarage}
                                    <svg class="w-3 h-3 text-white" fill="currentColor" viewBox="0 0 20 20">
                                        <path fill-rule="evenodd" d="M16.707 5.293a1 1 0 010 1.414l-8 8a1 1 0 01-1.414 0l-4-4a1 1 0 011.414-1.414L8 12.586l7.293-7.293a1 1 0 011.414 0z" clip-rule="evenodd"></path>
                                    </svg>
                                {/if}
                            </div>
                        </label>
                    </div>
                    <label for="garage" class="text-gray-300 text-sm cursor-pointer select-none">{$Locales["UI.IncludeGarage"]}</label>
                </div>
            </div>
        </div>

        <div class="bg-[#1e1e1e] border-t border-[#333333] px-6 py-4 flex justify-end">
            <button on:click={HandleSubmit} disabled={!selectedShell || price <= 0} class="bg-blue-400 text-white px-4 py-2 rounded-md text-sm font-medium hover:bg-blue-500 transition-colors disabled:opacity-50 disabled:cursor-not-allowed">
                {$Locales["UI.Create"]}
            </button>
        </div>

    </div>
</div>

<style>
    .sr-only {
        position: absolute;
        width: 1px;
        height: 1px;
        padding: 0;
        margin: -1px;
        overflow: hidden;
        clip: rect(0, 0, 0, 0);
        white-space: nowrap;
        border: 0;
    }
</style>