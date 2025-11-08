<script lang="ts">
	import { onMount } from "svelte";
	import { visibilityStore as visibility, Config, Current, House } from "$lib/stores/VisibilityStore";
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

	useNuiEvent("OpenHouseInteraction", (Data: any) => {
		visibility.show();
		Current.set("interaction");
		House.set(Data);
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
