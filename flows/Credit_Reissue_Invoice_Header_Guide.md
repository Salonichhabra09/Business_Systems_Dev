# Credit / Reissue Invoice Header — User Guide

## What this flow does

This flow creates a **Credit Note** invoice header by cloning an existing invoice header.  
It negates the quantities on the selected invoice lines, resets the clone to Draft status, and links it back to the original as its parent.

Use it when you need to reverse or partially reverse a submitted invoice — for example, to correct billing errors or process a customer credit.

---

## Before you start

Make sure the following are true before launching the flow:

| Check | Why it matters |
|-------|---------------|
| You are on the correct `Contract Invoice Header` record | The flow clones whichever record you launch it from |
| The invoice has at least one Invoice Line | You must select at least one line to attach to the credit note |
| You know the **original Invoice Date** and **Sun Invoice Number** (if the Invoice Date field is blank) | The flow will ask for these before proceeding |

---

## How to launch

1. Open the `Contract Invoice Header` record you want to credit or reissue.
2. Click the **Credit/Reissue Invoice Header** quick action button (in the action bar or related actions panel).
3. The flow will open as a guided screen.

---

## Step-by-step walkthrough

### Step 1 — Add Invoice Date *(only shown if Invoice Date is blank)*

If the Invoice Date on the original header is empty, the flow pauses here and asks you to provide it manually.

| Field | Required | Description |
|-------|----------|-------------|
| Original Invoice Date | Yes | The date of the original invoice from SUN |
| Original Sun Invoice Number | Yes | The SUN reference number for the original invoice (pre-filled if already on the record) |

Click **Continue** to proceed.

> If the Invoice Date is already populated, this screen is skipped automatically.

---

### Step 2 — Invoice Header Details

This is the main selection screen. It has two parts:

**Top section — Invoice Header Details component**  
Shows a summary of the new (cloned) credit note header that has been created in the background. Review the details to confirm they look correct.

**Bottom section — Invoice Lines datatable**  
Displays all invoice lines from the original header. You must select the lines you want to include on the credit note.

| Column | Editable | Description |
|--------|----------|-------------|
| Order Product | No | Name of the order product / service |
| Override Price | Yes | Optionally override the price for this credit line |
| Override Quantity | Yes | Optionally override the quantity (will be negated automatically) |
| Quantity | No | Original quantity from the order product |
| Invoice Line Total | No | Calculated total for the line |

**You must select at least one line** (the field is marked required).

Click **Next** when your selection is complete.

> Quantities on selected lines are automatically converted to negative values on the credit note — you do not need to enter negative numbers manually.

---

### Step 3 — Redirecting

The flow creates the selected invoice lines on the new credit note header and then redirects you to the new record automatically.

No action is required on this screen.

---

## What the flow sets on the new credit note

The following fields are set automatically — you do not need to fill these in:

| Field | Value set |
|-------|-----------|
| Invoice Status | Draft |
| Credit Note | True |
| Is Auto Created | True |
| Parent Invoice Header | Linked to the original invoice header |
| Invoice Name | `Credit of <original invoice name>` |
| Record Type | Invoice Header |
| GST Identification Number | Retained only if the GST record is currently active; cleared if inactive |
| Escalation Stage | Reset to `Level 0 - Not Due` |
| Sun fields (Invoice Number, Order Reference, etc.) | Cleared |
| Financial amount fields (Gross, Net, Transaction) | Cleared |
| Payment Due Date fields | Cleared |

---

## Error handling

### Invoice Header Cloning Failed

If the record cannot be cloned (e.g. a validation rule blocks it), the flow stops and displays an error screen:

> **Invoice Header Cloning Failed because of the following error.**  
> `<error message>`  
> **Please rectify the error and try again.**

Steps to resolve:
1. Note the error message shown on screen.
2. Click **Finish** to close the flow without making changes.
3. Fix the underlying issue on the original invoice header (e.g. missing required fields, failing validation rules).
4. Re-launch the flow.

---

## Frequently asked questions

**Will the original invoice be changed?**  
No. The flow only reads the original header and its lines. It creates a new separate credit note record and does not modify the original (unless the Invoice Date was blank — in that case, the original date and Sun Invoice Number are updated before cloning).

**What happens to lines I do not select?**  
They remain on the original invoice and are not included on the credit note.

**Why are quantities shown as negative on the credit note?**  
A credit note reverses the financial impact of the original invoice, so quantities must be negative. The flow handles this conversion automatically.

**Can I go back and change my line selection?**  
No — the back button is disabled on the Invoice Header Details screen. If you selected the wrong lines, click **Finish** to abandon the flow and start again from the original invoice header.

**The flow redirected me to the wrong record — what happened?**  
The redirect always goes to the newly created credit note header. If you need to return to the original, use the **Parent Invoice Header** lookup field on the credit note to navigate back.
