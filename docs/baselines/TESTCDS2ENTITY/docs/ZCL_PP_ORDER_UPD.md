# ZCL_PP_ORDER_UPD — Developer Documentation

**Object Type:** ABAP Class (CLAS/OC)  
**Package:** TESTCDS2ENTITY  
**Description:** Order update inbound  
**Visibility:** Public | Final | Private instantiation (factory pattern)  
**Generated:** 2026-07-23

---

## Overview

`ZCL_PP_ORDER_UPD` is an inbound interface handler that receives a production order change payload and applies it to the S/4HANA Production Order RAP Business Object (`I_ProductionOrderTP`) via Entity Manipulation Language (EML).

The class supports full lifecycle management of a production order's sub-objects:

| Sub-object | Create | Update | Delete |
|------------|--------|--------|--------|
| Header | — | ✓ (StorageLocation) | — |
| Operations | ✓ | ✓ | ✓ |
| Components | ✓ | ✓ | ✓ |
| Sequences | ✓ | — | ✓ |

All changes are applied atomically — a `COMMIT ENTITIES` / `COMMIT WORK` is issued on success; a `ROLLBACK ENTITIES` / `ROLLBACK WORK` on any failure. Every run is logged to the SAP Application Log (object `ZMESPRDORDUPDATE`).

---

## Architecture

```
Caller
  │
  ▼
factory( is_prod_order_x )          ← static factory method; creates instance
  │
  ▼
production_order_update( )          ← main entry point
  ├── read_in_production_order( )   ← EML READ: header, sequence, operation, component
  ├── validate_input( )             ← calls validate_teco( )
  ├── determine_action( )           ← delta comparison → populate mt_* create/update/delete tables
  ├── trigger_action( )             ← dispatches to EML MODIFY methods
  │     ├── update_header( )
  │     ├── create_operation( ) / update_operation( ) / delete_operation( )
  │     ├── create_component( ) / update_component( ) / delete_component( )
  │     └── create_sequence( ) / delete_sequence( )
  ├── COMMIT ENTITIES + COMMIT WORK
  └── log_save( )
```

On exception `ZCX_PP_ORDER_UPD`:
```
  ROLLBACK ENTITIES + ROLLBACK WORK → log_exception( ) → re-raise
```

---

## Public Interface

### Types

| Type | Description |
|------|-------------|
| `ty_header_read_result` | `TABLE FOR READ RESULT I_ProductionOrderTP` |
| `ty_operation_read_result` | `TABLE FOR READ RESULT I_ProductionOrderOperationTP` |
| `ty_sequence_read_result` | `TABLE FOR READ RESULT I_ProductionOrderSequenceTP` |
| `ty_component_read_result` | `TABLE FOR READ RESULT I_ProductionOrderOpComponentTP` |
| `ty_operation_link` | `TABLE FOR READ LINK I_ProductionOrderTP\_Operation` |
| `ty_component_link` | `TABLE FOR READ LINK I_ProductionOrderTP\\ProductionOrderOperation\_OperationComponent` |
| `tp_rap_messages` | Structure for collecting RAP error message details |
| `tt_rap_messages` | Standard table of `tp_rap_messages` |

### Constants

| Constant | Value | Purpose |
|----------|-------|---------|
| `cv_probclass_very_high` | `1` | Application Log problem class |
| `cv_probclass_high` | `2` | Application Log problem class |
| `cv_probclass_medium` | `3` | Application Log problem class |
| `cv_probclass_low` | `4` | Application Log problem class |
| `cv_probclass_none` | ` ` | Application Log problem class |

### Attributes

| Attribute | Type | Access | Purpose |
|-----------|------|--------|---------|
| `mv_log_handle` | `BALOGNR` | Read-only | App Log handle, default `'ZMESPRDORDUPDATE'` |
| `lt_rap_messages` | `tt_rap_messages` | Public | Accumulated RAP messages |
| `ls_rap_messages` | line of above | Public | Working line |
| `ms_prod_order_x` | `ZPP_S_PRODORDAPIX` | Read-only | Inbound payload (set at construction) |
| `mo_applog` | `REF TO if_reca_message_list` | Public | Application Log object |

### Methods

#### `factory` (static)
```abap
CLASS-METHODS factory
  IMPORTING is_prod_order_x         TYPE zpp_s_prodordapix
  RETURNING VALUE(ro_prod_order_upd) TYPE REF TO zcl_pp_order_upd
  RAISING   zcx_pp_order_upd
```
Creates and returns a new instance. Use this instead of `NEW` (constructor is private).

#### `production_order_update`
```abap
METHODS production_order_update
  RAISING zcx_pp_order_upd
```
Main processing method. Orchestrates the full update pipeline (read → validate → determine → apply → commit → log).

---

## Protected Interface

| Method | Parameters | Purpose |
|--------|------------|---------|
| `log_exception` | `io_cx TYPE REF TO cx_static_check` | Logs a caught exception to the Application Log |
| `log_success_step` | `iv_msg_txt TYPE TEXT50 OPTIONAL`, `iv_msg_typ TYPE SYMSGTY DEFAULT 'S'`, `iv_msg_lvl TYPE INT1 OPTIONAL` | Logs a success/informational step message |
| `log_save` | — | Saves (stores) the Application Log |

---

## Private Implementation Details

### Private Attributes

| Attribute | Type | Purpose |
|-----------|------|---------|
| `mv_productionordernum` | `AUFNR` | Production order number extracted from inbound payload |
| `mt_header_read_result` | `ty_header_read_result` | EML-read header result |
| `mt_sequence_read_result` | `ty_sequence_read_result` | EML-read sequence result |
| `mt_operation_read_result` | `ty_operation_read_result` | EML-read operations result |
| `mt_component_read_result` | `ty_component_read_result` | EML-read components result |
| `ms_header_update` | `ty_header_read_result` | Header records queued for update |
| `mt_operation_links` | `ty_operation_link` | Operation link data from EML read |
| `mt_operation_create/update/delete` | `ty_operation_read_result` | Operation action queues |
| `mt_sequence_create/delete` | `ty_sequence_read_result` | Sequence action queues |
| `mt_component_links` | `ty_component_link` | Component link data |
| `mt_component_create/update/delete` | `ty_component_read_result` | Component action queues |

### Private Method Reference

| Method | Description |
|--------|-------------|
| `constructor` | Stores `is_prod_order_x`, sets `mv_productionordernum`, creates Application Log via `CF_RECA_MESSAGE_LIST=>create` |
| `read_in_production_order` | EML `READ ENTITIES` for header, sequence, operations, and components. Raises `ZCX_PP_ORDER_UPD` on read failure |
| `validate_input` | Entry point for validation; currently delegates to `validate_teco` |
| `validate_teco` | Checks whether the production order has a `TechnicalCompletionDate` set (TECO status). Exception raise is currently commented out |
| `determine_action` | Compares inbound payload against EML-read database records; populates `mt_*_create`, `mt_*_update`, `mt_*_delete` tables based on `PARTACTION` flag (`I`=insert, `U`=update, `D`=delete) |
| `trigger_action` | Dispatches to `update_header`, and conditionally to create/update/delete methods for operations, components, and sequences |
| `update_header` | EML `MODIFY ENTITY I_ProductionOrderTP UPDATE FIELDS (StorageLocation)` |
| `create_operation` | EML `MODIFY ... CREATE BY \_operation`. Maps `VORNR`, `LTXA1`, `ARBPL`, standard work quantities, operation control profile |
| `update_operation` | EML `MODIFY ... UPDATE FIELDS` for operations; iterates `mt_operation_update` |
| `delete_operation` | EML `MODIFY ... EXECUTE delete` on `productionorderoperation` |
| `create_component` | EML `MODIFY ... CREATE BY \_operationcomponent`; resolves `OrderInternalID` from newly created operations if needed |
| `update_component` | EML `MODIFY ... UPDATE FIELDS` for components; updates `RequiredQuantity`, `BaseUnit`, `BillOfMaterialItemNumber` |
| `delete_component` | EML `MODIFY ... EXECUTE delete` on `productionordercomponent` |
| `create_sequence` | EML `MODIFY ... CREATE BY \_sequence`; maps `SequenceBranchOperation` and `SequenceReturnOperation` |
| `delete_sequence` | EML `MODIFY ... EXECUTE delete` on `ProductionOrderSequence` |
| `bdc_process` | Stub method — placeholder for a BDC batch input approach (not yet implemented) |

---

## Inbound Payload Structure

The class consumes `ZPP_S_PRODORDAPIX` which contains:

| Field | Description |
|-------|-------------|
| `head` | Header fields: `productionorder`, `storagelocation`, `batch`, `productionplant`, `product` |
| `operation[]` | Operation entries with `partaction` flag and standard work quantity fields |
| `components[]` | Component entries with `partaction`, `reservationitem`, quantity, BOM data |
| `sequence[]` | Sequence entries with `partaction`, `SequenceBranchOperation`, `SequenceReturnOperation` |

The `PARTACTION` field controls the action taken:
- `I` — Insert (create if not found in DB)
- `U` — Update (update if data changed from DB)
- `D` — Delete (delete if found in DB)

---

## Error Handling

All private methods raise `ZCX_PP_ORDER_UPD` on EML failure. Errors are surfaced by checking the `FAILED` and `REPORTED` return structures from EML statements and extracting long text via `%msg->if_message~get_longtext( )`.

The exception is re-raised with message class `ZPP_PRODORD` and message numbers:

| Message No. | Context |
|-------------|---------|
| `000` | Generic/header errors |
| `005` | Operation errors |
| `009` | Component errors |
| `010` | Sequence errors |

Application Log entries are persisted via `mo_applog->store()` on success, or after `log_exception` on failure.

---

## Known Issues / Code Quality Notes

1. **`bdc_process` is a stub** — The method body is empty (comment only). BDC processing is not implemented.
2. **`validate_teco` — exception raise is commented out** — The TECO check reads the header but the exception is commented out, meaning TECO orders are not blocked.
3. **`trigger_action` bug** — The component delete branch calls `delete_operation( )` instead of `delete_component( )`:
   ```abap
   IF mt_component_delete IS NOT INITIAL.
     delete_operation( ).   " BUG: should be delete_component( )
   ENDIF.
   ```
4. **`sy-batch` / `sy-binpt` assignment in `update_header`** — Directly assigning to system fields `sy-batch` and `sy-binpt` is not Clean Core compliant.
5. **Some operation/sequence error handling stubs** — Several `RAISE EXCEPTION` statements for edge cases (e.g., operation already exists on insert, operation not found on update) are commented out.
6. **`determine_action` — sequence handling** — Sequence update (`U`) case is not implemented; only insert and delete are handled.

---

## Usage Example

```abap
DATA(ls_payload) = VALUE zpp_s_prodordapix(
  head = VALUE #( productionorder = '000001000001'
                  storagelocation = '0001' )
  operation = VALUE #(
    ( partaction = 'U'
      productionorderoperation = '0010'
      operationtext = 'Milling updated'
      workcenter = 'MILL01' ) )
).

TRY.
  DATA(lo_updater) = zcl_pp_order_upd=>factory( is_prod_order_x = ls_payload ).
  lo_updater->production_order_update( ).
  MESSAGE 'Production order updated successfully' TYPE 'S'.
CATCH zcx_pp_order_upd INTO DATA(lx_err).
  MESSAGE lx_err TYPE 'E'.
ENDTRY.
```

---

## Dependencies

| Object | Type | Purpose |
|--------|------|---------|
| `I_ProductionOrderTP` | RAP Business Object | Target BO for all EML operations |
| `I_ProductionOrderOperationTP` | RAP BO entity | Operations sub-entity |
| `I_ProductionOrderSequenceTP` | RAP BO entity | Sequences sub-entity |
| `I_ProductionOrderOpComponentTP` | RAP BO entity | Components sub-entity |
| `I_ManufacturingOrderOperation` | CDS View | Used for `z_operation_data` type reference |
| `ZPP_S_PRODORDAPIX` | Structure | Inbound payload type |
| `ZCX_PP_ORDER_UPD` | Exception class | All raised exceptions |
| `IF_RECA_MESSAGE_LIST` | Interface | Application Log abstraction |
| `CF_RECA_MESSAGE_LIST` | Class | Application Log factory |
| `CL_MESSAGE_HELPER` | Class | Used in `log_exception` for T100 key extraction |
| `BAL_S_MSG`, `BALOGNR` | Dictionary types | Application Log structures |
