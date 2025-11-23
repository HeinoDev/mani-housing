<script lang="ts">
    import { Config } from "$lib/stores/VisibilityStore";
    import { fetchNui } from "$lib/utils/fetchNui";
    import { onMount, onDestroy, afterUpdate, tick } from 'svelte';
    let selectedCategory = Object.keys($Config?.Furniture || {})[0] || '';
    let searchTerm = '';
    let scrollContainer: HTMLDivElement;
    let currentScroll = 0;
    let targetScroll = 0;
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
        targetScroll = 0;
        currentScroll = 0;
        if (scrollContainer) {
            scrollContainer.scrollLeft = 0;
        }
    }
    function clampTarget() {
        if (scrollContainer) {
            const maxScroll = scrollContainer.scrollWidth - scrollContainer.clientWidth;
            targetScroll = Math.max(0, Math.min(targetScroll, maxScroll));
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
            targetScroll -= 212;
            clampTarget();
            if (!rafId) rafId = requestAnimationFrame(smoothScroll);
        }
    }
    function scrollRight() {
        if (scrollContainer) {
            targetScroll += 212;
            clampTarget();
            if (!rafId) rafId = requestAnimationFrame(smoothScroll);
        }
    }
    function smoothScroll() {
        if (Math.abs(currentScroll - targetScroll) < 1) {
            currentScroll = targetScroll;
            if (scrollContainer) {
                scrollContainer.scrollLeft = currentScroll;
                currentScroll = scrollContainer.scrollLeft; // Sync with browser clamp
            }
            rafId = null;
            return;
        }
        currentScroll += (targetScroll - currentScroll) * 0.15; // Adjust easing factor for smoothness (higher = faster)
        if (scrollContainer) {
            scrollContainer.scrollLeft = currentScroll;
            currentScroll = scrollContainer.scrollLeft; // Sync with browser clamp
        }
        rafId = requestAnimationFrame(smoothScroll);
    }
    onMount(async () => {
        await tick(); // Ensure DOM is updated
        if (scrollContainer) {
            currentScroll = scrollContainer.scrollLeft;
            targetScroll = currentScroll;
            clampTarget();
            const handleWheel = (e: WheelEvent) => {
                e.preventDefault();
                if (scrollContainer) {
                    targetScroll += e.deltaY;
                    clampTarget();
                    if (!rafId) {
                        rafId = requestAnimationFrame(smoothScroll);
                    }
                }
            };
            scrollContainer.addEventListener('wheel', handleWheel, { passive: false });
            return () => {
                scrollContainer.removeEventListener('wheel', handleWheel);
            };
        }
    });
    afterUpdate(async () => {
        await tick();
        clampTarget();
    });
    onDestroy(() => {
        if (rafId) {
            cancelAnimationFrame(rafId);
        }
    });
    // Reset scroll when search starts
    $: if (searchTerm && searchTerm.length > 0) {
        resetScroll();
    }
</script>

<div class="fixed inset-0 bg-black bg-opacity-50 select-none z-40">
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
                        <button
                            on:click={scrollLeft}
                            class="absolute left-2 top-1/2 -translate-y-1/2 z-20 bg-[#1a1a1a]/80 hover:bg-[#1a1a1a] text-white p-2 rounded-full transition-colors opacity-70 hover:opacity-100"
                            disabled={!scrollContainer || scrollContainer.scrollLeft <= 0}
                            style="pointer-events: {scrollContainer && scrollContainer.scrollLeft <= 0 ? 'none' : 'auto'}; opacity: {scrollContainer && scrollContainer.scrollLeft <= 0 ? '30%' : '70%'}"
                        >
                            <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                                <path d="m15 18-6-6 6-6"/>
                            </svg>
                        </button>
                        <div bind:this={scrollContainer} class="h-full p-3 overflow-x-auto overflow-y-hidden hide-scrollbar-horizontal snap-x snap-mandatory absolute inset-0">
                            <div class="grid grid-rows-[118px_118px] auto-cols-[200px] grid-flow-col gap-3 w-max h-full">
                                {#each displayFurniture as item (item.Model)}
                                    <div class="bg-[#1a1a1a] rounded-lg border border-[#333333] hover:border-blue-400 transition-all flex flex-col h-full p-2.5 shadow-sm hover:shadow-md snap-start">
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
                        <button
                            on:click={scrollRight}
                            class="absolute right-2 top-1/2 -translate-y-1/2 z-20 bg-[#1a1a1a]/80 hover:bg-[#1a1a1a] text-white p-2 rounded-full transition-colors opacity-70 hover:opacity-100"
                            disabled={!scrollContainer || scrollContainer.scrollLeft >= (scrollContainer.scrollWidth - scrollContainer.clientWidth)}
                            style="pointer-events: {scrollContainer && scrollContainer.scrollLeft >= (scrollContainer.scrollWidth - scrollContainer.clientWidth) ? 'none' : 'auto'}; opacity: {scrollContainer && scrollContainer.scrollLeft >= (scrollContainer.scrollWidth - scrollContainer.clientWidth) ? '30%' : '70%'}"
                        >
                            <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                                <path d="m9 18 6-6-6-6"/>
                            </svg>
                        </button>
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
        scroll-snap-type: x mandatory;
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