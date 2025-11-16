<script>
    import { createEventDispatcher } from 'svelte';
    const dispatch = createEventDispatcher();
    export let message = "Enter the price:";
    let price = '';
    function handleConfirm() {
        dispatch('confirm', price || null);
    }
    function handleCancel() {
        dispatch('confirm', null);
    }
</script>

<div class="fixed inset-0 flex items-center justify-center bg-black bg-opacity-50 select-none z-50">
    <div class="w-[400px] bg-[#121212] rounded-lg shadow-2xl border border-[#333333]">
        <header class="bg-[#1a1a1a] border-b border-[#333333] px-4 py-3 flex justify-between items-center">
            <div class="flex items-center">
                <h1 class="text-white font-medium">Set Price</h1>
            </div>
        </header>
        <main class="p-6">
            <p class="text-white mb-4">{message}</p>
            <input 
                bind:value={price} 
                type="number" 
                placeholder="Enter price..." 
                class="w-full bg-[#333333] text-white px-3 py-2 rounded-md text-sm focus:outline-none focus:ring-2 focus:ring-blue-400"
            />
            <div class="flex justify-end gap-3 mt-6">
                <button
                    onclick={handleCancel}
                    class="bg-gray-600 text-white px-4 py-2 rounded-md text-sm font-medium hover:bg-gray-700 transition-colors"
                >
                    Cancel
                </button>
                <button
                    onclick={handleConfirm}
                    class="bg-blue-600 text-white px-4 py-2 rounded-md text-sm font-medium hover:bg-blue-700 transition-colors"
                >
                    Confirm
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