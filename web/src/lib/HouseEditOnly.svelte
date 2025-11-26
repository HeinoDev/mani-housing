<script lang="ts">
    import { visibilityStore as visibility, House } from "$lib/stores/VisibilityStore";
    import { fetchNui } from "$lib/utils/fetchNui";
    import EditModal from "./components/EditModal.svelte";
    import Confirm from "./components/Confirm.svelte";
    import Input from "./components/Input.svelte";

    let showEditModal = true;
    let showConfirm = false;
    let showInput = false;
    let selectedHouseId: string | null = null;

    function CloseEditModal() {
        fetchNui("HideUI");
        visibility.hide();
    }

    function RemoveHouse() {
        CloseEditModal();
        showConfirm = true;
    }

    function handleConfirm(e) {
        showConfirm = false;
        if (e.detail) {
            if (selectedHouseId) {
                fetchNui("RemoveHouse", parseInt(selectedHouseId) + 1);
            }
            visibility.hide();
        }
    }

    function SellHouse() {
        showEditModal = false;
        showInput = true;
    }

    function handleSell(e) {
        showInput = false;
        if (e.type == "confirm" && selectedHouseId) {
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
    <EditModal houseId={$House.HouseId} on:close={CloseEditModal} on:remove={RemoveHouse} on:sell={SellHouse} />
{/if}

{#if showConfirm}
    <Confirm on:confirm={handleConfirm} message="Are you sure you want to remove this house?" />
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