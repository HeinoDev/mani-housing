<script lang="ts">
    import { Locales } from "$lib/stores/VisibilityStore";
    import { useNuiEvent } from "$lib/hooks/useNuiEvent";
    
    let Guide = {
        Key: 'E',
        Text: $Locales["UI.SelectEntrance"]
    };
    
    useNuiEvent("ChangeGuide", (Data: { Key: string; Text: string }) => {
        Guide = Data;
    });
</script>

<div class="fixed bottom-4 left-1/2 transform -translate-x-1/2 bg-[#1e1e1e] border border-[#333333] rounded-md px-4 py-2 text-gray-300 text-sm flex items-center gap-2 z-40 shadow-lg">
    <span>{$Locales["UI.Press"]}</span>
    <div class="bg-[#121212] border border-[#333333] rounded px-2 py-1 text-white font-medium text-xs">
        {Guide.Key}
    </div>
    <span>{Guide.Text}</span>
</div>