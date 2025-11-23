<script lang="ts">
    import { Config } from "$lib/stores/VisibilityStore";
    import { fetchNui } from "$lib/utils/fetchNui";
    import { onMount, onDestroy, tick } from 'svelte';
    let selectedCategory = Object.keys($Config?.Furniture || {})[0] || '';
    let searchTerm = '';
    let scrollContainer: HTMLDivElement;
    let isDragging = false;
    let startX = 0;
    let startScrollLeft = 0;
    let velocity = 0;
    let lastX = 0;
    let lastTime = 0;
    let rafId: number | null = null;
    $: categories = Object.keys($Config?.Furniture || {}).sort();  // Alphabetical order
    $: furniture = $Config?.Furniture[selectedCategory] || [];
    $: allFurniture = Object.entries($Config?.Furniture || {}).flatMap(([cat, items]) =>
        items.map(item => ({...item, category: cat}))
    );
    $: filteredAll = searchTerm
        ? allFurniture.filter(item =>
            item.Label.toLowerCase().includes(searchTerm.toLowerCase()) ||
            item.Model.toLowerCase().includes(searchTerm.toLowerCase())
        )
        : allFurniture;
    $: displayFurniture = searchTerm ? filteredAll : furniture;
    $: if (searchTerm) selectedCategory = '';
    function selectCategory(cat: string) {
        selectedCategory = cat;
        if (searchTerm) searchTerm = ''; // Clear search when selecting category
        resetScroll();
    }
    function resetScroll() {
        if (scrollContainer) {
            scrollContainer.scrollLeft = 0;
        }
    }
    function placeFurniture(item: any) {
        fetchNui("PlaceFurniture", {
            Model: item.Model,
            Label: item.Label,
            Price: item.Price
        });
    }
    function CloseUI() {
        fetchNui("HideDecorationUI");
    }
    function scrollLeft() {
        if (scrollContainer) {
            scrollContainer.scrollBy({ left: -212, behavior: 'smooth' });
        }
    }
    function scrollRight() {
        if (scrollContainer) {
            scrollContainer.scrollBy({ left: 212, behavior: 'smooth' });
        }
    }
    function handleMouseDown(e: MouseEvent) {
        isDragging = true;
        startX = e.pageX - scrollContainer!.offsetLeft;
        startScrollLeft = scrollContainer!.scrollLeft;
        lastX = startX;
        lastTime = Date.now();
        velocity = 0;
        scrollContainer!.style.cursor = 'grabbing';
        scrollContainer!.style.userSelect = 'none';
        if (rafId) cancelAnimationFrame(rafId);
        document.addEventListener('mousemove', handleMouseMove);
        document.addEventListener('mouseup', handleMouseUp);
    }
    function handleMouseMove(e: MouseEvent) {
        if (!isDragging || !scrollContainer) return;
        e.preventDefault();
        const x = e.pageX - scrollContainer.offsetLeft;
        const now = Date.now();
        if (lastTime) {
            const deltaX = x - lastX;
            const deltaT = now - lastTime;
            if (deltaT > 0) {
                velocity = deltaX / deltaT;
            }
        }
        lastX = x;
        lastTime = now;
        const walk = (x - startX) * 0.8; // Further reduced sensitivity for slower drag
        scrollContainer.scrollLeft = startScrollLeft - walk;
    }
    function handleMouseUp() {
        if (!isDragging || !scrollContainer) return;
        isDragging = false;
        scrollContainer.style.cursor = 'grab';
        scrollContainer.style.userSelect = '';
        document.removeEventListener('mousemove', handleMouseMove);
        document.removeEventListener('mouseup', handleMouseUp);
        // Apply momentum if there's any velocity
        if (Math.abs(velocity) > 0.1) { // Lowered threshold for more responsive momentum
            momentumScroll();
        }
    }
    function momentumScroll() {
        if (!scrollContainer || Math.abs(velocity) < 0.01) {
            rafId = null;
            return;
        }
        const walk = velocity * 12; // Reduced walk for less momentum
        scrollContainer.scrollLeft -= walk;
        velocity *= 0.88; // Increased friction for quicker stop
        rafId = requestAnimationFrame(momentumScroll);
    }
    function handleKeyDown(e: KeyboardEvent) {
        if (e.key === 'Alt' && e.location === KeyboardEvent.DOM_KEY_LOCATION_LEFT) {
            ToggleFocus();
        }
    }
    onMount(async () => {
        await tick();
        if (scrollContainer) {
            scrollContainer.style.cursor = 'grab';
        }
        document.addEventListener('keydown', handleKeyDown);
    });
    onDestroy(() => {
        if (isDragging) {
            document.removeEventListener('mousemove', handleMouseMove);
            document.removeEventListener('mouseup', handleMouseUp);
        }
        if (rafId) {
            cancelAnimationFrame(rafId);
        }
        document.removeEventListener('keydown', handleKeyDown);
    });
    // Reset scroll when search starts
    $: if (searchTerm && searchTerm.length > 0) {
        resetScroll();
    }
    function ToggleFocus() {
        fetchNui("ToggleFocus");
    }
</script>
<div class="fixed inset-0 select-none z-40">
    <div class="fixed bottom-0 left-0 right-0 w-full h-[450px] flex flex-col overflow-hidden">
        <div class="flex flex-1 overflow-hidden">
            <aside class="w-1/5 min-w-[200px] bg-[#1e1e1e] border-r border-[#333333] flex flex-col h-full rounded-t-md shadow-2xl flex-shrink-0">
                <header class="bg-[#1a1a1a] border-b border-[#333333] px-4 py-3 flex justify-between items-center rounded-t-md">
                    <div class="flex items-center">
                        <h1 class="text-white font-medium">Furniture</h1>
                    </div>
                    <div class="flex items-center gap-4">
                        <button on:click={CloseUI} class="text-gray-400 hover:text-white">
                            <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><line x1="18" y1="6" x2="6" y2="18"></line><line x1="6" y1="6" x2="18" y2="18"></line></svg>
                        </button>
                    </div>
                </header>
                <div class="p-4">
                    <input bind:value={searchTerm} placeholder="Search furniture..." class="bg-[#333333] text-white px-3 py-2 rounded-md text-sm focus:outline-none focus:ring-2 focus:ring-blue-400 w-full mb-4" />
                </div>
                <div class="flex-1 overflow-y-auto hide-scrollbar p-4 space-y-2">
                    {#each categories as cat}
                        <button
                            on:click={() => selectCategory(cat)}
                            class="w-full text-left px-3 py-2 rounded-md text-sm transition-colors {selectedCategory === cat ? 'bg-blue-400 text-white' : 'text-gray-400 hover:text-white'}"
                        >
                            {cat}
                        </button>
                    {/each}
                    {#if searchTerm}
                        <div class="text-blue-400 text-sm px-3 py-2">Search Results ({displayFurniture.length})</div>
                    {/if}
                </div>
            </aside>
            <main class="flex-1 flex items-end relative">
                {#if displayFurniture.length > 0}
                    <div class="w-full h-[272px] bg-[#1e1e1e] rounded-b-md border border-[#333333] overflow-hidden shadow-2xl relative">
                        <div
                            bind:this={scrollContainer}
                            on:mousedown|preventDefault={handleMouseDown}
                            class="h-full p-3 overflow-x-auto overflow-y-hidden hide-scrollbar-horizontal absolute inset-0 select-none"
                        >
                            <div class="grid grid-rows-[118px_118px] auto-cols-[200px] grid-flow-col gap-3 w-max h-full">
                                {#each displayFurniture as item (item.Model)}
                                    <div class="bg-[#1a1a1a] rounded-lg border border-[#333333] hover:border-blue-400 transition-all flex flex-col h-full p-2.5 shadow-sm hover:shadow-md">
                                        {#if searchTerm && item.category}
                                            <div class="text-xs text-gray-400 mb-1">{item.category}</div>
                                        {/if}
                                        <div class="flex-1 mb-2 flex flex-col justify-between">
                                            <div>
                                                <h3 class="text-white font-medium text-sm mb-1 line-clamp-1">{item.Label}</h3>
                                                <p class="text-gray-400 text-xs line-clamp-1">Model: {item.Model}</p>
                                            </div>
                                        </div>
                                        <div class="flex justify-between items-center mt-auto text-sm">
                                            <span class="text-green-400 font-medium">${item.Price.toLocaleString()}</span>
                                            <button
                                                on:click={() => placeFurniture(item)}
                                                class="bg-blue-400 text-white px-3 py-1 rounded-md font-medium hover:bg-blue-500 transition-colors whitespace-nowrap"
                                            >
                                                Place
                                            </button>
                                        </div>
                                    </div>
                                {/each}
                            </div>
                        </div>
                        <!-- Fade indicator on right -->
                        <div class="absolute right-0 top-0 bottom-0 w-8 bg-gradient-to-l from-[#1e1e1e] to-transparent pointer-events-none z-10"></div>
                    </div>
                {:else}
                    <div class="w-full h-[272px] bg-[#1e1e1e] rounded-b-md border border-[#333333] flex items-center justify-center text-gray-400 text-sm shadow-2xl">No furniture found</div>
                {/if}
            </main>
        </div>
    </div>
</div>
<style lang="css">
    .hide-scrollbar::-webkit-scrollbar {
        display: none;
    }
   
    .hide-scrollbar {
        -ms-overflow-style: none;  /* IE and Edge */
        scrollbar-width: none;  /* Firefox */
        -webkit-overflow-scrolling: touch;
    }
    .hide-scrollbar-horizontal::-webkit-scrollbar {
        display: none;
    }
    .hide-scrollbar-horizontal {
        -ms-overflow-style: none;
        scrollbar-width: none;
        -webkit-overflow-scrolling: touch;
    }
    * {
        user-select: none;
        -webkit-user-select: none;
        -moz-user-select: none;
        -ms-user-select: none;
    }
    .line-clamp-1 {
        display: -webkit-box;
        -webkit-line-clamp: 1;
        -webkit-box-orient: vertical;
        overflow: hidden;
    }
    button:disabled {
        opacity: 0.3;
        cursor: not-allowed;
    }
</style>