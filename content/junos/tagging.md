+++
title = 'Tagging'
date = 2025-04-14T16:52:11-04:00
draft = false
+++


## Junos VLAN Tagging Options Explained

Here's a comparison of `vlan-tagging`, `flexible-vlan-tagging`, and `encapsulation flexible-ethernet-services`.

### 1. `vlan-tagging`

*   **Configuration Level:** Physical Interface (`set interfaces <interface-name> vlan-tagging`)
*   **Purpose:** Enables basic IEEE 802.1Q VLAN tagging support on the physical interface.
*   **Capabilities:**
    *   Allows logical units (`unit`) under this interface to be configured with a *single* VLAN ID (`set interfaces <interface-name> unit <number> vlan-id <id>`).
    *   Supports sending and receiving standard single-tagged Ethernet frames.
    *   Can support one untagged VLAN using the `native-vlan-id` option on the physical interface.
*   **Limitations:**
    *   Does *not* natively support receiving or sending double-tagged (QinQ/Stacked VLAN) frames on logical units.
    *   Does *not* easily support mixing tagged and untagged traffic across *different* logical units on the same physical interface (only one native/untagged VLAN is easily supported for the whole port).
    *   Limited flexibility in VLAN mapping per logical unit.
*   **Typical Use Case:**
    *   Standard "trunk" ports connecting to switches or other routers where multiple VLANs, each identified by a single tag, need to be carried.
    *   Simple Layer 2 or Layer 3 sub-interfaces.
*   **Example:**
    ```junos
    # Configure the physical interface for basic single-tagging
    set interfaces ge-0/0/1 vlan-tagging
    set interfaces ge-0/0/1 native-vlan-id 10  # Optional: VLAN 10 is untagged

    # Configure logical units with single VLAN IDs
    set interfaces ge-0/0/1 unit 100 vlan-id 100
    set interfaces ge-0/0/1 unit 100 family inet address 192.168.100.1/24

    set interfaces ge-0/0/1 unit 200 vlan-id 200
    set interfaces ge-0/0/1 unit 200 family inet address 192.168.200.1/24
    ```

---

### 2. `flexible-vlan-tagging`

*   **Configuration Level:** Physical Interface (`set interfaces <interface-name> flexible-vlan-tagging`)
*   **Purpose:** Enables advanced VLAN tagging capabilities, allowing for more complex scenarios on a single physical interface.
*   **Capabilities:**
    *   Supports logical units with *single* VLAN IDs (`vlan-id`).
    *   Supports logical units with *double* (stacked/QinQ) VLAN tags (`vlan-tags outer <tag> inner <tag>`).
    *   Supports logical units accepting *untagged* traffic (`vlan-id none`, though configuration details vary slightly by platform/scenario).
    *   Allows mixing single-tagged, double-tagged, and untagged logical units on the *same* physical interface.
    *   Supports VLAN ID lists and ranges on logical units (`vlan-id-list [ list-of-vlans ]`).
    *   Often a prerequisite for advanced Layer 2 features and services.
*   **Limitations:**
    *   Slightly more complex configuration as each logical unit's tagging requirement must be explicitly defined.
*   **Typical Use Case:**
    *   QinQ deployments (Service Provider NNI, Enterprise Campus).
    *   Interfaces needing to handle a mix of single-tagged customer traffic and double-tagged infrastructure traffic.
    *   Interfaces where some services are tagged and others are untagged.
    *   Aggregation points requiring flexible VLAN mapping.
*   **Example:**
    ```junos
    # Configure the physical interface for advanced tagging
    set interfaces xe-0/1/0 flexible-vlan-tagging

    # Configure a logical unit for single-tagged traffic
    set interfaces xe-0/1/0 unit 101 description "Single Tagged Customer A"
    set interfaces xe-0/1/0 unit 101 vlan-id 101
    set interfaces xe-0/1/0 unit 101 family bridge # Example for L2

    # Configure a logical unit for double-tagged (QinQ) traffic
    set interfaces xe-0/1/0 unit 500 description "QinQ Customer B (Outer 500, Inner 50)"
    set interfaces xe-0/1/0 unit 500 vlan-tags outer 500 inner 50
    set interfaces xe-0/1/0 unit 500 family bridge # Example for L2

    # Configure a logical unit for untagged traffic (config might vary slightly)
    # This often requires specific encapsulation like vlan-bridge or ethenet-bridge
    set interfaces xe-0/1/0 unit 0 description "Untagged Management"
    set interfaces xe-0/1/0 unit 0 encapsulation vlan-bridge
    # Note: No 'vlan-id' or 'vlan-tags' means it might handle untagged frames if configured correctly
    set interfaces xe-0/1/0 unit 0 family inet address 10.0.0.1/24

    # Configure a logical unit accepting a list of VLANs
    set interfaces xe-0/1/0 unit 999 description "VLAN List Service"
    set interfaces xe-0/1/0 unit 999 vlan-id-list [ 200 205-210 300 ]
    set interfaces xe-0/1/0 unit 999 encapsulation vlan-bridge
    ```

---

### 3. `encapsulation flexible-ethernet-services`

*   **Configuration Level:** Physical Interface (`set interfaces <interface-name> encapsulation flexible-ethernet-services`)
*   **Purpose:** Primarily used on MX Series routers (and some other platforms) to allow a *mix of different Layer 2 encapsulation types* (like bridge, ccc, vpls) on different logical units of the *same* physical interface. It fundamentally changes how the interface PFE (Packet Forwarding Engine) processes frames to support this service flexibility.
*   **Capabilities:**
    *   Allows logical units (`unit`) under the same physical interface to have different Ethernet service encapsulations (e.g., `encapsulation vlan-bridge`, `encapsulation vlan-ccc`, `encapsulation vlan-vpls`, `encapsulation ethernet-ccc`, etc.).
    *   Enables maximum service multiplexing onto a single physical port.
*   **Important Note:** This option *must often be used in conjunction with `flexible-vlan-tagging`* if the services running on the logical units need to handle tagged frames (single or double). `flexible-ethernet-services` defines the *service type* flexibility, while `flexible-vlan-tagging` defines the *VLAN tag* flexibility.
*   **Limitations:**
    *   Platform-specific (mainly MX Series).
    *   Adds configuration complexity.
    *   Cannot be combined with `vlan-tagging` on the same physical interface.
*   **Typical Use Case:**
    *   Service Provider edge routers (PE) terminating multiple customers with different L2VPN service types (E-Line/CCC, E-LAN/VPLS, E-Tree) or bridging requirements on the same physical link (NNI or UNI).
    *   Data Center interconnects requiring diverse L2 service types.
*   **Example:**
    ```junos
    # Configure the physical interface for flexible service encapsulations AND flexible tagging
    set interfaces xe-0/2/0 encapsulation flexible-ethernet-services
    set interfaces xe-0/2/0 flexible-vlan-tagging

    # Logical unit for a bridged service (single tag)
    set interfaces xe-0/2/0 unit 1000 description "Bridged Service VLAN 1000"
    set interfaces xe-0/2/0 unit 1000 encapsulation vlan-bridge
    set interfaces xe-0/2/0 unit 1000 vlan-id 1000

    # Logical unit for a VPLS service (QinQ tag)
    set interfaces xe-0/2/0 unit 2000 description "VPLS Service Outer 200 Inner 20"
    set interfaces xe-0/2/0 unit 2000 encapsulation vlan-vpls
    set interfaces xe-0/2/0 unit 2000 vlan-tags outer 200 inner 20

    # Logical unit for a CCC/L2Circuit service (single tag)
    set interfaces xe-0/2/0 unit 3000 description "CCC/E-Line Service VLAN 3000"
    set interfaces xe-0/2/0 unit 3000 encapsulation vlan-ccc
    set interfaces xe-0/2/0 unit 3000 vlan-id 3000
    ```

---

### Summary Table

| Feature                     | `vlan-tagging`                       | `flexible-vlan-tagging`              | `encapsulation flexible-ethernet-services` (+ `flexible-vlan-tagging`) |
| :-------------------------- | :----------------------------------- | :----------------------------------- | :--------------------------------------------------------------------- |
| **Config Level**            | Physical Interface                   | Physical Interface                   | Physical Interface                                                     |
| **Primary Purpose**         | Basic 802.1Q tagging                 | Advanced VLAN tagging (QinQ, Mixed)  | Mix different L2 service types on units                                |
| **Single Tag Support**      | Yes (via `vlan-id` on unit)          | Yes (via `vlan-id` on unit)          | Yes (if `flexible-vlan-tagging` also used)                           |
| **Double Tag (QinQ) Support**| No                                   | Yes (via `vlan-tags` on unit)        | Yes (if `flexible-vlan-tagging` also used)                           |
| **Untagged Support**        | Yes (one `native-vlan-id`)           | Yes (per unit, requires specific config) | Yes (per unit, requires specific config)                             |
| **Mixed Tag/Untagged Units**| No (except native)                   | Yes                                  | Yes                                                                    |
| **VLAN Lists/Ranges**       | No                                   | Yes                                  | Yes                                                                    |
| **Mixed L2 Encapsulations per Port** | No                           | No                                   | Yes (e.g., bridge, ccc, vpls on same port)                             |
| **Common Platforms**        | All Junos platforms                  | Most modern Junos platforms          | Primarily MX Series (and some others like PTX, ACX)                    |
| **Use When...**             | Simple trunk port, single tags only. | Need QinQ, mix tagged/untagged, VLAN lists. | Need to mix L2VPN service types (VPLS, CCC, Bridge) on one port (MX). |

---

**In essence:**

*   Use `vlan-tagging` for the simplest trunk port needs.
*   Use `flexible-vlan-tagging` when you need any advanced VLAN tagging like QinQ or mixing tagged/untagged traffic on different units of the same port.
*   Use `encapsulation flexible-ethernet-services` (usually *with* `flexible-vlan-tagging`) on platforms like MX when you need to run different *types* of Layer 2 services (bridging, VPLS, CCC, etc.) concurrently on logical units sharing the same physical interface.
