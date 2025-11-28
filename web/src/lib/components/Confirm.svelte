<script>
    import { Locales } from "$lib/stores/VisibilityStore";
    import { createEventDispatcher } from 'svelte';
    const dispatch = createEventDispatcher();

    export let message = $Locales["UI.AreYouSure"];

    function handleConfirm() {
        dispatch('confirm', true);
    }

    function handleCancel() {
        dispatch('confirm', false);
    }
</script>

<div class="fixed inset-0 flex items-center justify-center bg-black bg-opacity-50 select-none z-50">
    <div class="w-[400px] bg-[#121212] rounded-lg shadow-2xl border border-[#333333]">
        <header class="bg-[#1a1a1a] border-b border-[#333333] px-4 py-3 flex justify-between items-center">
            <div class="flex items-center">
                <h1 class="text-white font-medium">{$Locales["UI.Confirm"]}</h1>
            </div>
        </header>

        <main class="p-6">
            <p class="text-white mb-6">{message}</p>
            <div class="flex justify-end gap-3">
                <button 
                    onclick={handleCancel} 
                    class="bg-gray-600 text-white px-4 py-2 rounded-md text-sm font-medium hover:bg-gray-700 transition-colors"
                >
                    {$Locales["UI.Cancel"]}
                </button>
                <button 
                    onclick={handleConfirm} 
                    class="bg-blue-600 text-white px-4 py-2 rounded-md text-sm font-medium hover:bg-blue-700 transition-colors"
                >
                    {$Locales["UI.Confirm"]}
                </button>
            </div>
        </main>
    </div>
</div>

<style>
    * {
        user-select: none;
        -webkit-user-select: none;
        -moz-user-select: none;
        -ms-user-select: none;
    }
</style>
