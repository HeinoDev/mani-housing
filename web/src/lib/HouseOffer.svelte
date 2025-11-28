<script>
    import { visibilityStore as visibility, House, Locales } from "$lib/stores/VisibilityStore";
    import { fetchNui } from "$lib/utils/fetchNui";
    import Confirm from "./components/Confirm.svelte";

    let showConfirm = false;

    function CloseUI() {
        fetchNui("HideUI");
        visibility.hide();
    }

    function signOffer() {
        showConfirm = true;
    }

    function handleConfirm(e) {
        showConfirm = false;
        if (e.detail) {
            fetchNui("PurchaseHouse", $House.HouseId);
            visibility.hide();
        }
    }
</script>

<div class="fixed inset-0 flex items-center justify-center bg-black bg-opacity-50 select-none z-50">
    <div class="bg-[#121212] rounded-lg shadow-2xl border border-[#333333] w-80">
        <header class="bg-[#1a1a1a] border-b border-[#333333] px-4 py-3 flex justify-between items-center">
            <div class="flex items-center">
                <h1 class="text-white font-medium mr-2">
                    {$House.Coords?.Zone ?? 'Unknown Zone'}:
                </h1>
                <h1 class="text-blue-400 font-medium">
                    {$House.HouseId}
                </h1>
            </div>
            <button onclick={CloseUI} class="text-gray-400 hover:text-white transition-colors">
                <i class="fas fa-times"></i>
            </button>
        </header>

        <main class="p-4">
            <div class="mb-4">
                <h2 class="text-white font-semibold mb-2">{$Locales["UI.HouseInformation"]}</h2>
                <div class="bg-[#1a1a1a] rounded-md border border-[#333333] p-3">
                    <div class="text-sm">
                        <div class="flex justify-between mb-1">
                            <span class="text-gray-400">{$Locales["UI.Shell"]}:</span>
                            <span class="text-white">{$House.Shell}</span>
                        </div>
                    </div>
                </div>
            </div>

            {#if $House.SalesData}
                <div class="mb-4">
                    <h2 class="text-white font-semibold mb-2">{$Locales["UI.SalesData"]}</h2>
                    <div class="bg-[#1a1a1a] rounded-md border border-[#333333] p-3 space-y-2">
                        <div class="flex justify-between">
                            <span class="text-gray-400">{$Locales["UI.Price"]}:</span>
                            <span class="text-white font-semibold">${$House.SalesData.Price}</span>
                        </div>
                        <div class="flex justify-between">
                            <span class="text-gray-400">{$Locales["UI.RealEstateJob"]}:</span>
                            <span class="text-white">{$House.SalesData.SalesmanJobLabel}</span>
                        </div>
                        <div class="flex justify-between">
                            <span class="text-gray-400">{$Locales["UI.Agent"]}:</span>
                            <span class="text-white">{$House.SalesData.Salesman}</span>
                        </div>
                    </div>
                </div>
            {/if}

            <div class="flex justify-end mt-4">
                <button 
                    onclick={signOffer}
                    class="bg-blue-600 text-white px-4 py-2 rounded-md text-sm font-medium hover:bg-blue-700 transition-colors"
                >
                    {$Locales["UI.SignTheOffer"]}
                </button>
            </div>
        </main>
    </div>
</div>

{#if showConfirm}
    <Confirm on:confirm={handleConfirm} message={$Locales["UI.SignOfferConfirm"]} />
{/if}

<style>
    * {
        user-select: none;
        -webkit-user-select: none;
        -moz-user-select: none;
        -ms-user-select: none;
    }
</style>
