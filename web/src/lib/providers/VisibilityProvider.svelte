<script lang="ts">
	import { onMount } from "svelte";
	import { visibilityStore as visibility, Config, Current } from "$lib/stores/VisibilityStore";
	import { useNuiEvent } from "$lib/hooks/useNuiEvent";
	import { fetchNui } from "$lib/utils/fetchNui";

	onMount(() => {
		const keyHandler = (e: KeyboardEvent) => {
			if ($visibility && e.code === "Escape") {
				fetchNui("HideUI");
				visibility.hide();
			}
		};

		window.addEventListener("keydown", keyHandler);
		return () => window.removeEventListener("keydown", keyHandler);
	});

	useNuiEvent("OpenRealestate", () => {
		visibility.show();
		Current.set("main");
	});

	useNuiEvent("HideUI", () => {
		visibility.hide();
	});

	useNuiEvent("InitializeUI", (Data: any) => {
		Config.set(Data);
	});
</script>

{#if $visibility}
	<slot />
{/if}
