<script lang="ts">
	import MainMenu from "$lib/MainMenu.svelte";
	import Guide from "$lib/components/Guide.svelte";
	import VisibilityProvider from "$lib/providers/VisibilityProvider.svelte";
	import { Current } from "$lib/stores/VisibilityStore";
</script>

<VisibilityProvider>
	{#if $Current == "main"}
		<MainMenu />
	{/if}

	{#if $Current == "guide"}
		<Guide />
	{/if}
</VisibilityProvider>