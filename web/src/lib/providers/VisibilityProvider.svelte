<script lang="ts">
	import { onMount } from "svelte";
	import { visibilityStore as visibility, Config, Current, House, Houses } from "$lib/stores/VisibilityStore";
	import { useNuiEvent } from "$lib/hooks/useNuiEvent";
	import { fetchNui } from "$lib/utils/fetchNui";

	onMount(() => {
		const keyHandler = (e: KeyboardEvent) => {
			if ($visibility && e.code === "Escape") {
				visibility.hide();

				if ($Current == "decor")
				{
					fetchNui("StopDecorating");
				}
				else
				{
					fetchNui("HideUI");
				}
				
			}
		};

		window.addEventListener("keydown", keyHandler);
		return () => window.removeEventListener("keydown", keyHandler);
	});

	useNuiEvent("OpenRealestate", (Data: any) => {
		visibility.show();
		Houses.set(Data);
		Current.set("main");
	});

	useNuiEvent("OpenHouseStats", (Data: any) => {
		visibility.show();
		House.set(Data);
		Current.set("editonly");
	});

	useNuiEvent("OpenHouseInteraction", (Data: any) => {
		visibility.show();
		Current.set("interaction");
		House.set(Data);
	});

	useNuiEvent("OpenHouseOffer", (Data: any) => {
		visibility.show();
		Current.set("offer");
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
