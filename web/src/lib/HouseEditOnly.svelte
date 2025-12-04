<script lang="ts">
    import { visibilityStore as visibility, House, Locales } from "$lib/stores/VisibilityStore";
    import { fetchNui } from "$lib/utils/fetchNui";
    import EditModal from "./components/EditModal.svelte";
    import Confirm from "./components/Confirm.svelte";
    import Input from "./components/Input.svelte";

    let showEditModal = true;
    let showConfirm = false;
    let showInput = false;

    function CloseEditModal() {
        fetchNui("HideUI");
        visibility.hide();
    }

    function RemoveHouse() {
        showEditModal = false;
        showConfirm = true;
    }

    function handleConfirm(e) {
        showConfirm = false;
        if (e.detail) {
            fetchNui("RemoveHouse", $House.HouseId);
            visibility.hide();
        }
        else
        {
            showEditModal = true;
        }
    }

    function SellHouse() {
        showEditModal = false;
        showInput = true;
    }

    function handleSell(e) {
        showInput = false;
        if (e.type == "confirm") {
            fetchNui("SellHouse", {
                HouseId: $House.HouseId,
                Price: e.detail
            });
            visibility.hide();
        }
        else
        {
            showEditModal = true;
        }
    }
</script>

{#if showEditModal}
    <EditModal on:close={CloseEditModal} on:remove={RemoveHouse} on:sell={SellHouse} />
{/if}

{#if showConfirm}
    <Confirm on:confirm={handleConfirm} message={$Locales["UI.RemoveHouseConfirm"]} />
{/if}

{#if showInput}
    <Input on:confirm={handleSell} />
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