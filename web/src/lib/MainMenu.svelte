<script lang="ts">
    import { visibilityStore as visibility, Current, Houses } from "$lib/stores/VisibilityStore";
    import { fetchNui } from "$lib/utils/fetchNui";
    import CreateModal from "./components/CreateModal.svelte";
    import EditModal from "./components/EditModal.svelte";
    import Confirm from "./components/Confirm.svelte";
    import Input from "./components/Input.svelte";
    let showCreateModal = false;
    let showEditModal = false;
    let showConfirm = false;
    let showInput = false;
    let selectedHouseId: string | null = null;
    let searchTerm = '';
    let onlyInactive = false;
    $: entries = Object.entries($Houses || {});
    $: filteredHouses = entries
        .filter(([key, house]) => {
            if (!house) return false;
            if (onlyInactive && house.State == 1) return false;
            const label = `${house.Coords.Zone}: ${house.HouseId}`;
            const owner = house.SalesData?.OwnerName || '';
            return label.toLowerCase().includes(searchTerm.toLowerCase()) || owner.toLowerCase().includes(searchTerm.toLowerCase());
        })
        .map(([key, house]) => ({ id: key, house }))
        .slice(0, 30);
   
    function CloseUI() {
        fetchNui("HideUI");
        visibility.hide();
    }
   
    function CreateHouse() {
        showCreateModal = true;
    }
   
    function HandleCreateHouse(event: CustomEvent) {
        fetchNui("CreateHouse", event.detail);
        Current.set("guide");
        showCreateModal = false;
    }
   
    function CloseCreateModal() {
        showCreateModal = false;
    }
    function EditHouse(houseId: string) {
        selectedHouseId = houseId;
        showEditModal = true;
    }
    function CloseEditModal() {
        showEditModal = false;
    }
    function ViewLocation(houseId: string) {
        fetchNui("ViewLocation", parseInt(houseId) + 1);
        visibility.hide();
    }
    function RemoveHouse() {
        CloseEditModal();
        showConfirm = true;
    }
    function handleConfirm(e) {
        showConfirm = false;
        if (e.detail) {
            if (selectedHouseId) {
                fetchNui("RemoveHouse", parseInt(selectedHouseId) + 1);
            }
            visibility.hide();
        }
    }
    function SellHouse() {
        showEditModal = false;
        showInput = true;
    }
    function handleSell(e) {
        showInput = false;
        if (e.type == "confirm" && selectedHouseId) {
            const house = $Houses[selectedHouseId];
            if (house) {
                fetchNui("SellHouse", {
                    HouseId: house.HouseId,
                    Price: e.detail
                });
            }
            visibility.hide();
        }
    }
</script>
<div class="fixed inset-0 flex items-center justify-center bg-black bg-opacity-50 select-none">
    <div class="w-[800px] h-[560px] bg-[#121212] rounded-md shadow-2xl flex flex-col overflow-hidden border border-[#333333]">
        <header class="bg-[#1a1a1a] border-b border-[#333333] px-4 py-3 flex justify-between items-center">
            <div class="flex items-center">
                <h1 class="text-white font-medium">Real Estate</h1>
            </div>
            <div class="flex items-center gap-4">
                <button onclick={CloseUI} class="text-gray-400 hover:text-white">
                    <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><line x1="18" y1="6" x2="6" y2="18"></line><line x1="6" y1="6" x2="18" y2="18"></line></svg>
                </button>
            </div>
        </header>
        <div class="bg-[#1e1e1e] border-b border-[#333333] px-4 py-2">
            <div class="flex items-center">
                <div class="flex items-center gap-2 mr-auto">
                    <span class="text-gray-400 text-sm">Houses:</span>
                    <span class="text-blue-400 font-medium">{filteredHouses.length}</span>
                </div>
                <div class="flex-1 flex justify-center px-4">
                    <input bind:value={searchTerm} placeholder="Search houses..." class="bg-[#333333] text-white px-3 py-1 rounded-md text-sm focus:outline-none focus:ring-2 focus:ring-blue-400 w-full max-w-md" />
                </div>
                <div class="flex items-center gap-4 ml-auto">
                    <div class="flex items-center gap-2">
                        <div class="relative flex items-center">
                            <input type="checkbox" bind:checked={onlyInactive} id="inactive" class="sr-only peer">
                            <label for="inactive" class="relative flex items-center cursor-pointer">
                                <div class="w-5 h-5 bg-[#1e1e1e] border-2 border-[#333333] rounded peer-checked:bg-blue-400 peer-focus:ring-2 peer-focus:ring-blue-400 transition-all duration-200 peer-checked:border-blue-400"></div>
                                <div class="absolute inset-0 w-5 h-5 flex items-center justify-center pointer-events-none">
                                    {#if onlyInactive}
                                        <svg class="w-3 h-3 text-white" fill="currentColor" viewBox="0 0 20 20">
                                            <path fill-rule="evenodd" d="M16.707 5.293a1 1 0 010 1.414l-8 8a1 1 0 01-1.414 0l-4-4a1 1 0 011.414-1.414L8 12.586l7.293-7.293a1 1 0 011.414 0z" clip-rule="evenodd"></path>
                                        </svg>
                                    {/if}
                                </div>
                            </label>
                        </div>
                        <span class="text-xs text-gray-400">Only Inactive</span>
                    </div>
                    <button onclick={CreateHouse} class="bg-blue-400 text-white px-3 py-1 rounded-md text-sm font-medium hover:bg-blue-500 transition-colors">
                        Create House
                    </button>
                </div>
            </div>
        </div>
        <div class="flex-1 overflow-y-auto hide-scrollbar p-4 space-y-4">
            <div class="grid grid-cols-1 gap-4">
                {#each filteredHouses as item}
                    <div class="bg-[#1a1a1a] rounded-lg p-3 border border-[#333333] hover:border-blue-400 transition-colors flex flex-col h-full">
                        <div class="flex justify-between items-start mb-2">
                            <h3 class="text-white font-medium text-sm">{item.house.Coords.Zone}: {item.house.HouseId}</h3>
                            <div class="flex flex-row items-center gap-1">
                                <button onclick={() => EditHouse(item.id)} class="text-blue-400 hover:text-blue-300 p-1">
                                    <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                                        <path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"></path>
                                        <path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z"></path>
                                    </svg>
                                </button>
                                <button onclick={() => ViewLocation(item.id)} class="text-blue-400 hover:text-blue-300 p-1">
                                    <i class="fas fa-map-marker-alt text-xs"></i>
                                </button>
                            </div>
                        </div>
                        {#if item.house.SalesData?.OwnerName}
                            <p class="text-gray-400 text-xs mb-3">Owner: {item.house.SalesData.OwnerName}</p>
                        {/if}
                        <p class="text-gray-400 text-xs mb-3">Shell: {item.house.Shell}</p>
                        <div class="flex-1"></div>
                        <div class="flex justify-between items-center space-y-2">
                            <div class="flex flex-wrap gap-1">
                                {#if item.house.Coords.Garage}
                                    <span class="bg-gray-700 text-xs px-2 py-1 rounded">Garage</span>
                                {/if}
                                {#if item.house.Coords.Wardrobe}
                                    <span class="bg-gray-700 text-xs px-2 py-1 rounded">Wardrobe</span>
                                {/if}
                                {#if item.house.Coords.Stash}
                                    <span class="bg-gray-700 text-xs px-2 py-1 rounded">Stash</span>
                                {/if}
                            </div>
                            <span class="text-green-400 text-sm font-medium">${item.house.SalesData?.Price?.toLocaleString() || '0'}</span>
                        </div>
                    </div>
                {/each}
            </div>
        </div>
    </div>
</div>
{#if showCreateModal}
    <CreateModal on:submit={HandleCreateHouse} on:close={CloseCreateModal} />
{/if}
{#if showEditModal}
    <EditModal houseId={selectedHouseId} on:close={CloseEditModal} on:remove={RemoveHouse} on:sell={SellHouse} />
{/if}
{#if showConfirm}
    <Confirm on:confirm={handleConfirm} message="Are you sure you want to remove this house?" />
{/if}
{#if showInput}
    <Input on:confirm={handleSell} />
{/if}
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