/* ============================================================
   easyLwcBridge.js — bridges LWC (easyRelatedObjectForm / easyDocumentUpload) state into the VF page. Loaded AFTER easyCore.js.
   ============================================================ */

const lwcRelatedRecordCounts = {};

docReady(function () {
    document.addEventListener('lwcrelatedobjectchange', function (event) {
        // event.target is the <c-easy-related-object-form> host, which has no id itself —
        // the id lives on the wrapping .easy-ro-container div injected by the VF page.
        const container = event.target && event.target.closest && event.target.closest('.easy-ro-container[id]');
        if (container) {
            lwcRelatedRecordCounts[container.id] = event.detail.recordCount;
        }
    });
});

/**
 * Tracks document upload state reported by easyDocumentUpload LWC components.
 * Keyed by the container div id ("easy-du-{requirementItemId}").
 * Updated whenever the LWC fires the composed "lwcdocumentuploadchange" event.
 * Each value is an object: { hasDocument: Boolean, isRequired: Boolean }
 */
const lwcDocumentUploadStates = {};

docReady(function () {
    document.addEventListener('lwcdocumentuploadchange', function (event) {
        // event.target is the <c-easy-document-upload> host, which has no id itself —
        // the id lives on the wrapping .easy-du-container div injected by the VF page.
        const container = event.target && event.target.closest && event.target.closest('.easy-du-container[id]');
        if (container) {
            lwcDocumentUploadStates[container.id] = event.detail;
        }
    });
});
