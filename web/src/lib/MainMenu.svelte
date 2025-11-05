<script lang="ts">
    import { visibilityStore as visibility, Current } from "$lib/stores/VisibilityStore";
    import { fetchNui } from "$lib/utils/fetchNui";
    import CreateModal from "./components/CreateModal.svelte";

    let showCreateModal = false;
    
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
</script>

<div class="fixed inset-0 flex items-center justify-center bg-black bg-opacity-50 select-none">
    <div class="w-[1000px] h-[700px] bg-[#121212] rounded-md shadow-2xl flex flex-col overflow-hidden border border-[#333333]">
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
            <div class="flex items-center justify-between">
                <div class="flex items-center gap-4">
                    <div class="flex items-center gap-2">
                        <span class="text-gray-400 text-sm">Houses:</span>
                        <span class="text-blue-400 font-medium">1 (Make this)</span>
                    </div>
                </div>
                <button onclick={CreateHouse} class="bg-blue-400 text-white px-3 py-1 rounded-md text-sm font-medium hover:bg-blue-500 transition-colors">
                    Create House
                </button>
            </div>
        </div>
    </div>
</div>

{#if showCreateModal}
    <CreateModal on:submit={HandleCreateHouse} on:close={CloseCreateModal} />
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