<script lang="ts">
    import { visibilityStore as visibility, House } from "$lib/stores/VisibilityStore";
    import { fetchNui } from "$lib/utils/fetchNui";

    let expanded = $state({});
    let editingPermissions = $state({});

    function toggleExpanded(identifier: string, data: any) {
        if (!expanded[identifier]) {
            editingPermissions[identifier] = {
                Enter: data.Permissions.Enter,
                Garage: data.Permissions.Garage
            };
        }
        expanded[identifier] = !expanded[identifier];
    }

    function savePermissions(identifier: string) {
        // const perms = editingPermissions[identifier];
        // fetchNui("UpdateKeyPermissions", {
        //     houseId: $House.HouseId,
        //     identifier,
        //     permissions: perms
        // });
        // // Update the store with new permissions
        // $House.Keyholders[identifier].Permissions = { ...perms };
        // // Clear editing state
        // delete editingPermissions[identifier];
        // // Close dropdown
        // expanded[identifier] = false;
    }

    function removeKeyholder(identifier: string) {
        // fetchNui("RemoveKeyholder", {
        //     houseId: $House.HouseId,
        //     identifier
        // });
        // Remove from store
        // delete $House.Keyholders[identifier];
    }

    function addKeyholder() {
        // fetchNui("AddKeyholder", {
        //     houseId: $House.HouseId,
        //     identifier: newIdentifier,
        //     character: newCharacter
        // });
    }

    function placeWardrobe() {
        // fetchNui("PlaceWardrobe", { houseId: $House.HouseId });
    }

    function placeStash() {
        // fetchNui("PlaceStash", { houseId: $House.HouseId });
    }

    function CloseUI() {
        fetchNui("HideUI");
        visibility.hide();
    }
</script>

<div class="fixed inset-0 flex items-center justify-center bg-black bg-opacity-50 select-none">
    <div class="w-[1000px] h-[700px] bg-[#121212] rounded-lg shadow-2xl flex flex-col overflow-hidden border border-[#333333]">
        <header class="bg-[#1a1a1a] border-b border-[#333333] px-4 py-3 flex justify-between items-center">
            <div class="flex items-center">
                <h1 class="text-white font-medium mr-2">{$House.Coords?.Zone ?? 'Unknown Zone'}:</h1>
                <h1 class="text-blue-400 font-medium">{$House.HouseId}</h1>
            </div>
            <div class="flex items-center gap-4">
                <button onclick={CloseUI} class="text-gray-400 hover:text-white transition-colors">
                    <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                        <line x1="18" y1="6" x2="6" y2="18"></line>
                        <line x1="6" y1="6" x2="18" y2="18"></line>
                    </svg>
                </button>
            </div>
        </header>

        <main class="flex-1 p-6 overflow-y-auto hide-scrollbar flex flex-row space-x-6">
            <!-- Keyholders Section (Left) -->
            <div class="flex-1 bg-[#1a1a1a] rounded-lg border border-[#333333] p-4 flex flex-col">
                <div class="flex items-center justify-between mb-4">
                    <h2 class="text-white font-semibold text-lg flex items-center">
                        <svg xmlns="http://www.w3.org/2000/svg" class="w-5 h-5 mr-2 text-yellow-400" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15.232 5.232l3.536 3.536m-2.036-5.036a2.5 2.5 0 113.536 3.536L6.5 21.036H3v-3.572L16.732 3.732z" />
                        </svg>
                        Keyholders
                    </h2>
                    <div class="flex items-center gap-2">
                        <span class="text-gray-400 text-sm">({Object.keys($House.Keyholders ?? {}).length})</span>
                        <button onclick={() => showAddForm = true} class="text-blue-400 hover:text-blue-300 text-sm font-medium transition-colors">
                            + Add
                        </button>
                    </div>
                </div>
                <div class="flex-1 overflow-y-auto space-y-3">
                    {#if $House.Keyholders && Object.keys($House.Keyholders).length > 0}
                        {#each Object.entries($House.Keyholders) as [identifier, data]}
                            <div class="bg-[#1e1e1e] rounded-md border border-[#333333] overflow-hidden transition-all duration-200 hover:shadow-md hover:border-blue-400/50">
                                <!-- Main Card -->
                                <div 
                                    class="p-3 cursor-pointer flex items-center justify-between hover:bg-[#2a2a2a] transition-colors" 
                                    onclick={() => toggleExpanded(identifier, data)}
                                >
                                    <div class="flex items-center gap-3 flex-1">
                                        <div class="w-8 h-8 bg-blue-400/10 rounded-full flex items-center justify-center flex-shrink-0">
                                            <svg xmlns="http://www.w3.org/2000/svg" class="w-4 h-4 text-blue-400" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z" />
                                            </svg>
                                        </div>
                                        <div class="min-w-0 flex-1">
                                            <p class="text-white font-medium truncate text-sm">{data.Character}</p>
                                        </div>
                                    </div>
                                    <div class="flex items-center gap-2 ml-2 flex-shrink-0">
                                        <button onclick={(e) => { e.stopPropagation(); removeKeyholder(identifier); }} class="text-red-400 hover:text-red-300 p-1 transition-colors" title="Remove Keyholder">
                                            <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                                                <polyline points="3,6 5,6 21,6"></polyline>
                                                <path d="M19,6v14a2,2,0,0,1-2,2H7a2,2,0,0,1-2-2V6m3,0V4a2,2,0,0,1,2-2h4a2,2,0,0,1,2,2v2"></path>
                                            </svg>
                                        </button>
                                        <svg xmlns="http://www.w3.org/2000/svg" class="w-3 h-3 text-gray-400 transition-transform duration-200" fill="none" viewBox="0 0 24 24" stroke="currentColor" style:transform={expanded[identifier] ? 'rotate(180deg)' : 'rotate(0deg)'}>
                                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 9l-7 7-7-7" />
                                        </svg>
                                    </div>
                                </div>
                                
                                <!-- Dropdown/Expanded Section -->
                                {#if expanded[identifier]}
                                    <div class="bg-[#2a2a2a] px-3 py-2 border-t border-[#333333] space-y-3">
                                        <div class="space-y-2">
                                            <div class="flex items-center justify-between">
                                                <label class="text-gray-300 text-xs flex items-center gap-1">
                                                    <svg xmlns="http://www.w3.org/2000/svg" class="w-3 h-3 text-gray-400" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 12l2-2m0 0l7-7 7 7M5 10v10a1 1 0 001 1h3m10-11l2 2m-2-2v10a1 1 0 01-1 1h-3m-6 0a1 1 0 001-1v-4a1 1 0 011-1h2a1 1 0 011 1v4a1 1 0 001 1m-6 0h6" />
                                                    </svg>
                                                    Enter
                                                </label>
                                                <div class="relative flex items-center">
                                                    <input type="checkbox" bind:checked={editingPermissions[identifier].Enter} id="enter-{identifier}" class="sr-only peer" />
                                                    <label for="enter-{identifier}" class="relative flex items-center cursor-pointer">
                                                        <div class="w-4 h-4 bg-[#1e1e1e] border-2 border-[#333333] rounded peer-checked:bg-blue-400 peer-focus:ring-2 peer-focus:ring-blue-400 transition-all duration-200 peer-checked:border-blue-400"></div>
                                                        <div class="absolute inset-0 w-4 h-4 flex items-center justify-center pointer-events-none">
                                                            {#if editingPermissions[identifier].Enter}
                                                                <svg class="w-2.5 h-2.5 text-white" fill="currentColor" viewBox="0 0 20 20">
                                                                    <path fill-rule="evenodd" d="M16.707 5.293a1 1 0 010 1.414l-8 8a1 1 0 01-1.414 0l-4-4a1 1 0 011.414-1.414L8 12.586l7.293-7.293a1 1 0 011.414 0z" clip-rule="evenodd"></path>
                                                                </svg>
                                                            {/if}
                                                        </div>
                                                    </label>
                                                </div>
                                            </div>
                                            <div class="flex items-center justify-between">
                                                <label class="text-gray-300 text-xs flex items-center gap-1">
                                                    <svg xmlns="http://www.w3.org/2000/svg" class="w-3 h-3 text-gray-400" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 14l-7 7m0 0l-7-7m7 7V3" />
                                                    </svg>
                                                    Garage
                                                </label>
                                                <div class="relative flex items-center">
                                                    <input type="checkbox" bind:checked={editingPermissions[identifier].Garage} id="garage-{identifier}" class="sr-only peer" />
                                                    <label for="garage-{identifier}" class="relative flex items-center cursor-pointer">
                                                        <div class="w-4 h-4 bg-[#1e1e1e] border-2 border-[#333333] rounded peer-checked:bg-blue-400 peer-focus:ring-2 peer-focus:ring-blue-400 transition-all duration-200 peer-checked:border-blue-400"></div>
                                                        <div class="absolute inset-0 w-4 h-4 flex items-center justify-center pointer-events-none">
                                                            {#if editingPermissions[identifier].Garage}
                                                                <svg class="w-2.5 h-2.5 text-white" fill="currentColor" viewBox="0 0 20 20">
                                                                    <path fill-rule="evenodd" d="M16.707 5.293a1 1 0 010 1.414l-8 8a1 1 0 01-1.414 0l-4-4a1 1 0 011.414-1.414L8 12.586l7.293-7.293a1 1 0 011.414 0z" clip-rule="evenodd"></path>
                                                                </svg>
                                                            {/if}
                                                        </div>
                                                    </label>
                                                </div>
                                            </div>
                                        </div>
                                        <div class="pt-1 border-t border-[#333333] flex justify-end">
                                            <button 
                                                onclick={() => savePermissions(identifier)} 
                                                class="bg-blue-600 hover:bg-blue-700 text-white px-3 py-1 rounded text-xs font-medium transition-colors"
                                            >
                                                Save
                                            </button>
                                        </div>
                                    </div>
                                {/if}
                            </div>
                        {/each}
                    {/if}
                </div>
            </div>

            <!-- Right Side: Sales Data and Administrate -->
            <div class="flex-1 flex flex-col space-y-6">
                <!-- Sales Data Section -->
                {#if $House.SalesData}
                    <div class="bg-[#1a1a1a] rounded-lg border border-[#333333] p-4 flex flex-col">
                        <h2 class="text-white font-semibold mb-4 text-lg flex items-center">
                            <svg xmlns="http://www.w3.org/2000/svg" class="w-5 h-5 mr-2 text-green-400" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8c-1.657 0-3 .895-3 2s1.343 2 3 2 3 .895 3 2-1.343 2-3 2m0-8c1.11 0 2.08.402 2.599 1M12 8V7m0 1v8m0 0v1m0-1c-1.11 0-2.08-.402-2.599-1" />
                            </svg>
                            Sales Data
                        </h2>
                        <div class="space-y-3 text-sm">
                            <div class="bg-[#1e1e1e] rounded-md border border-[#333333] p-3">
                                <div class="flex items-center justify-between">
                                    <span class="text-gray-400 flex items-center gap-1">
                                        <svg xmlns="http://www.w3.org/2000/svg" class="w-4 h-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8c-1.657 0-3 .895-3 2s1.343 2 3 2 3 .895 3 2-1.343 2-3 2m0-8c1.11 0 2.08.402 2.599 1M12 8V7m0 1v8m0 0v1m0-1c-1.11 0-2.08-.402-2.599-1" />
                                        </svg>
                                        Price
                                    </span>
                                    <span class="text-white font-semibold">${$House.SalesData.Price}</span>
                                </div>
                            </div>
                            <div class="bg-[#1e1e1e] rounded-md border border-[#333333] p-3">
                                <div class="flex items-center justify-between">
                                    <span class="text-gray-400 flex items-center gap-1">
                                        <svg xmlns="http://www.w3.org/2000/svg" class="w-4 h-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 21V5a2 2 0 00-2-2H7a2 2 0 00-2 2v16m14 0h2m-2 0h-5m-9 0H3m2 0h5M9 7h1m-1 4h1m4-4h1m-1 4h1m-5 10v-5a1 1 0 011-1h2a1 1 0 011 1v5m-4 0h4" />
                                        </svg>
                                        Real Estate Job
                                    </span>
                                    <span class="text-white">{$House.SalesData.SalesmanJob}</span>
                                </div>
                            </div>
                            <div class="bg-[#1e1e1e] rounded-md border border-[#333333] p-3">
                                <div class="flex items-center justify-between">
                                    <span class="text-gray-400 flex items-center gap-1">
                                        <svg xmlns="http://www.w3.org/2000/svg" class="w-4 h-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z" />
                                        </svg>
                                        Agent
                                    </span>
                                    <span class="text-white">{$House.SalesData.Salesman}</span>
                                </div>
                            </div>
                        </div>
                    </div>
                {/if}

                <!-- Administrate Section -->
                <div class="flex-1 bg-[#1a1a1a] rounded-lg border border-[#333333] p-4 flex flex-col">
                    <h2 class="text-white font-semibold mb-4 text-lg flex items-center">
                        <svg xmlns="http://www.w3.org/2000/svg" class="w-5 h-5 mr-2 text-purple-400" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10.325 4.317c.426-1.756 2.924-1.756 3.35 0a1.724 1.724 0 002.573 1.066c1.543-.94 3.31.826 2.37 2.37a1.724 1.724 0 001.065 2.572c1.756.426 1.756 2.924 0 3.35a1.724 1.724 0 00-1.066 2.573c.94 1.543-.826 3.31-2.37 2.37a1.724 1.724 0 00-2.572 1.065c-.426 1.756-2.924 1.756-3.35 0a1.724 1.724 0 00-2.573-1.066c-1.543.94-3.31-.826-2.37-2.37a1.724 1.724 0 00-1.065-2.572c-1.756-.426-1.756-2.924 0-3.35a1.724 1.724 0 001.066-2.573c-.94-1.543.826-3.31 2.37-2.37.996.608 2.296.07 2.572-1.065z" />
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z" />
                        </svg>
                        Administrate
                    </h2>
                    <div class="space-y-3">
                        <button onclick={placeWardrobe} class="w-full bg-[#1e1e1e] border border-[#333333] rounded-md p-3 text-left hover:bg-[#2a2a2a] transition-colors text-sm text-white flex items-center gap-3">
                            <svg xmlns="http://www.w3.org/2000/svg" class="w-5 h-5 text-purple-400" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 11l7-7 7 7M5 19l7-7 7 7" />
                            </svg>
                            Place Wardrobe
                        </button>
                        <button onclick={placeStash} class="w-full bg-[#1e1e1e] border border-[#333333] rounded-md p-3 text-left hover:bg-[#2a2a2a] transition-colors text-sm text-white flex items-center gap-3">
                            <svg xmlns="http://www.w3.org/2000/svg" class="w-5 h-5 text-purple-400" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M20 7l-8-4-8 4m16 0l-8 4m8-4v10l-8 4m0-10L4 7m8 4v10M4 7v10l8 4" />
                            </svg>
                            Place Stash
                        </button>
                    </div>
                </div>
            </div>
        </main>
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