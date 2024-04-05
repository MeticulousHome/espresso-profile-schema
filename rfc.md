# RequestForCoffe: Open Espresso Profile Format

## Status of This specification

This document describes the standardized format for espresso brewing profiles known as the Open Espresso Profile Format (OEPF),
intended for use in programmable espresso machines. This document provides a current draft of the endavours to combine multiple
commercial and internet community based approaches to coffee profiles. 

## Abstract

The  Open Espresso Profile Format (OEPF) utilizes JSON to encode detailed instructions for the espresso brewing process,
allowing users to specify temperatures, pressures, flow rates, and more. The profile does encode a deterministic finite atomaton
at the current stage but is intended to be extended with an additional Domain Specific Language (DSL) in the future which
will allow for full turing completeness in the profile brewing process.
This document delineates the OPFS's structure, including the rationale behind each component's design and provides guidelines on how espresso machines should interpret and execute these profiles.
The OEPF documentation, schema and sample code are licences under the GNU General Public License Version 3 and all text and code implementing, tranforming, analysing or providing schemas or profiles are to be considered derived works and to be released under the same licence.

## 1. Introduction

The development of the OEPF aims to bridge the gap between espresso brewing artistry and machine automation,
providing a means for enthusiasts and professionals alike to share and replicate espresso brewing recipies.
By defining a clear and detailed structure for brewing profiles, the OEPF ensures compatibility and repeatability
across different devices, skyrocketing the collaboration and innovation of espresso brewing.

## 2. Terminology

- **Espresso**: A full-flavored, concentrated form of coffee served in "shots." It's made by forcing pressurized hot water through very finely ground coffee beans using an espresso machine.
- **Espresso Shot**: A concentrated coffee beverage brewed by forcing a small amount of nearly boiling water through finely-ground coffee beans.
- **Brew**: The process of making coffee by steeping coffee grounds in hot water. In the context of espresso, it refers to the act of creating the espresso shot.
- **Brew Ratio**: The ratio of coffee to water used in brewing an espresso shot, which significantly affects the flavor and strength of the espresso. Common ratios include 1:1 for ristrettos, 1:2 for standard espresso shots, and 1:3 for lungos.
- **Profile**: A comprehensive set of instructions for brewing espresso, structured as JSON and described in this document.
- **Stage**: A discrete phase in the espresso brewing process, defined within a profile with specific parameters and conditions.
- **Variable**: A named parameter within a profile that can be adjusted and referenced by stages.
- **Exit Trigger**: A condition defined within a stage that, when met, signals the transition to the next stage.
- **Limits**: Constraints applied to stages to prevent exceeding specific parameter values.
- **UUID**: Universally Unique Identifier, utilized for ensuring global uniqueness across profiles and authors.
- **JSON**: JavaScript Object Notation, a lightweight format for data interchange.

## 3.Capabilities of Espresso Machines

The development of the OEPF took into consideration the advanced capabilities of specific espresso machines, recognizing their unique features that significantly influence brewing techniques and outcomes. Among these, the following workgroups were influencial to this document:
- Decent Espresso
- Meticulous Home

#### The Decent Espresso Machine
Decent Espresso Machines are renowned for their ability to precisely control temperature throughout the brewing process. This capability allows for temperature profiling, where the water temperature can be adjusted dynamically as the espresso shot is pulled. This feature is crucial for extracting the full range of flavors from the coffee, as different compounds are more soluble at different temperatures.

Special Capabilities:
    - make use of the temperature_delta field within the stages

### The Meticulous Espresso Machine
The Meticulous Espresso Machine, on the other hand, distinguishes itself with its ability to control the relative power of the piston. This level of control over the piston's power allows for nuanced adjustments to the pressure profile, directly affecting the extraction rate and flavor profile of the espresso shot.

Special Capabilities:
    - ability to use piston position as an additional sensor value


## 4. Design considerations
The inclusion of different machines with vastely different capabilities into the design considerations of the OEPF highlights the specification's adaptability to both factory-designed capabilities and community-driven innovations. By accommodating all the enhanced features provided by the different projects OEPF ensures a wide applicability, not only bridging the gap between traditional espresso machines and the desires of the modern coffee enthusiast for precision and control but also vaporizing the idea of a walled garden per machine ecosystem.

### Handling Incompatibilities in Machine Capabilities

Not all machines will be capable of executing every type of stage defined in a profile due to hardware or software limitations.
For example, a machine may not support precise control over certain variables like the piston position or the lever motor power as
not all machines are motorized leaver machines. In these cases, the machine should:

- **Provide interpretation fallback** if it can accomplish the idea of the stage but at a lower precision or with a slightly different outcome. The user should be informed of this during import.
- **Approximate stages** within its capabilities, adjusting parameters to the closest possible values and notifying the user of the modifications.
- **Halt import execution** if a stage is critical to the profile's integrity and cannot be approximated, alerting the user to the inability to proceed. This might be a stage where the temperature difference between the stages is substantially significant while the machine doesn't provide any temperature profiling capabilities. It should ensure it is aborting not just a tweak of the reciples core idea but the main idea of the recipe.

## 5. Profile Structure

The OEPF structure is intentionally designed to encapsulate the complexity of espresso brewing in a format that is both flexible and precise. Below, we explore the rationale behind key elements of the profile structure.

#### 5.1 Name

- **Purpose**: Facilitates easy identification and comparison of profiles.
- **Design Decision**: Keeping the name non-unique allows for creative freedom and ease in organizing profiles.

#### 5.2 ID

- **Purpose**: Ensures distinct identification of each profile.
- **Design Decision**: UUID-v4 is chosen for its global uniqueness, crucial for sharing and versioning profiles.

#### 5.3 Author and Author ID

- **Purpose**: Credits the profile's creator and tracks ownership.
- **Design Decision**: Combining a readable name with a UUID ensures clarity in attribution and supports a system of rights management.

#### 5.4 Previous Authors

- **Purpose**: Maintains a record of contributions and changes over time.
- **Design Decision**: An array of previous authors supports transparency and collaboration, encouraging the evolution of profiles.

#### 5.5 Temperature and Final Weight

- **Purpose**: Defines key brewing parameters.

#### 5.6 Variables

- **Purpose**: Introduces flexibility within profiles.
- **Design Decision**: Variables within a coffee brewing profile serve as customizable parameters that can be referenced and are injected across different stages of the brewing process. They also provide a flexible mechanism for adjusting the brewing parameters dynamically between shots in minimal editors. They can be used in the stages dynamics points, exit triggers and limiters.

#### Fields Within a Variable entry

- **name**: Serves as a descriptive and easily recognizable identifier for the variable. It is used within the user interface (UI) of the coffee machine or profile editing tools to present a readable name that users can associate with a specific parameter or setting. The name should be unique within the profile to avoid confusion.

- **key**: Acts as a unique identifier for the variable within the scope of the profile. It is crucial for programmatically referencing and manipulating the variable's value during the brewing process. The key must be unique across all variables defined in the profile to ensure that each variable can be distinctly identified and accessed.

- **type**: Specifies the category or nature of the variable, indicating what aspect of the brewing process it controls or influences. The type is defined as an enumeration (enum) that includes options such as "power," "flow," and "pressure." This categorization helps the brewing engine understand how to interpret the variable's value and apply it to control the machine's components accordingly.


- **type**: Specifies the category or nature of the variable, indicating what aspect of the brewing process it controls or influences. The type is defined as an enumeration (enum) that includes options such as "power," "flow," and "pressure" among others. This categorization helps a potential UI to understand how to interpret the variable's value and expose it to the user for manipulation.
    - **time**: Measures time intervals within the brewing process.
        - **Range**: 0 to TBD (180s to 24h)
        - **Resolution**: 0.1 seconds
    - **weight**: Tracks the weight of coffee output or input materials.
        - **Range**: 0 to 2000g
        - **Resolution**: 0.1 grams
    - **pressure**: Indicates the water pressure used during extraction.
        - **Range**: 0 to 12 bar
        - **Resolution**: 0.1 bar
    - **flow**: Measures the rate at which water flows through the coffee grounds.
        - **Range**: 0 to 12 bar
        - **Resolution**: 0.1 bar
    - **piston_position**: Represents the position of a lever or piston in machines.
        - **Range**: 0 to 100%
        - **Resolution**: 1%
    - **temperature**: Specifies the water temperature for brewing.
        - **Range**: 0 to 150°C or 99°C for machines with ambient pressure heating
        - **Resolution**: 0.1°C
    - **power**: Relates to the electrical power used by the machine's lever actuator.
        - **Range**: 0 to 100%
        - **Resolution**: 1%

- **value**: The actual setting or magnitude assigned to the variable, represented as a numeric value without unit.

#### Utilizing Variables in Brewing Execution

- In the dynamics of a stage, variables can define target values across stage bounderies and to hit certain target key performances
- Exit triggers may use variables to determine when a stage should end, such as reaching a certain pressure or flow rate which
- Limits ensure that the brewing process adheres to safety and quality constraints by capping the pressure and/or flow.

Variables are to be set prior to the start of the brewing process and can therefore be preprocessed in higher programming languages then what might be used for the profile execution engine.

#### 5.7 Stages

- **Purpose**: Describes the brewing process in detail.
- **Design Decision**: The structured approach to stages, including dynamics, exit triggers, and limits, provides a comprehensive control mechanism over the brewing sequence. In most cases customers want the machine to do only one (visible) task at a time. As power, pressure and flow are dependant on each other allowing the control of multiple of these at once is non beneficitial. It was therefore chose to stick to the tried and true "one stage at a time"-approach.

#### 5.8 Fields Within a Stage

- **name**: A human-readable identifier for the stage. It helps users and developers understand the purpose and sequence of the brewing process.

- **key**: A unique identifier for the stage within the profile. It facilitates referencing and managing stages programmatically, ensuring that actions and logs can be accurately associated with the correct stage of the process.

- **type**: Specifies the nature of the stage, such as "power," "flow," or "pressure." This field informs the machine about the primary control mechanism or parameter of the stage, guiding the execution logic in adjusting machine settings accordingly.

- **dynamics**: An object detailing how the stage's primary parameter should vary over time or in response to other variables. It includes:
    - **points**: An array of tuples (pairs) specifying key values for the parameter over time or relative to another variable, forming a graph of desired outcomes.
    - **over**: Indicates the variable over which the dynamics are mapped (e.g., "piston_position," "time," "weight"), determining the x-axis of the dynamics graph.
    - **interpolation**: Specifies how the machine should transition between points (e.g., "linear," "curve," "spring"), affecting the smoothness and nature of the parameter's change over time.

- **exit_triggers**: An array of conditions that determine when the stage should end, transitioning to the next stage or concluding the brewing process. Each trigger includes:
    - **type**: The kind of condition to monitor (e.g., "weight," "pressure," "time"), directing the machine on what sensor feedback or internal timer to evaluate.
    - **value**: The specific threshold that activates the trigger, indicating when the stage's goal has been achieved or a certain limit has been reached.
    - **relative**: (Optional) A boolean indicating whether the trigger's value is relative to the start of the stage or absolute.
    - **comparison**: (Optional) Specifies whether the trigger activates when the monitored value is "greater" or "less" than the specified value, adding flexibility in defining exit conditions.

- **limits**: (Optional) Constraints applied to parameters within the stage to prevent exceeding the machine's capabilities or safety thresholds. Each limit specifies:
    - **type**: The parameter to constrain (e.g., "flow," "pressure"), ensuring that the stage does not push the machine beyond safe operational bounds.
    - **value**: The maximum or minimum allowable value for the parameter, acting as a safeguard during the stage's execution.

### 6. Execution of Profiles

Machines execute stages sequentially, adjusting output parameters with its accuators as defined in a stages dynamics until an exit trigger condition or the global final weight is met.
For the execution of a profile the following steps are to be taken:

1. **Set Temperature**: Adjusts water temperature to match the `temperature` field from the profile.
2. **Select First Stage**: Begins execution with the first stage outlined in the profile.
3. **Log Stage Entry**: Records key parameters (weight, flow, pressure, and time) upon entering a stage.
4. **Evaluate Exit Triggers**: Checks if conditions to exit the current stage are met, based on defined `exitTriggers`. If the profile is not completed and another stage is next, it repeats from step 3.
5. **Interpolate Points**: Calculates the current setpoint by interpolating points within the stage for the specified parameter (e.g., pressure, flow).
6. **Actuate Based on Stage Type**: Activates the appropriate actuator (e.g., for pressure, flow) to adjust the machine towards the calculated setpoint.
7. **Apply Limiters**: Ensures actuators do not exceed defined `limits` for parameters like flow or pressure.

These steps are executed in a loop until the profile is completed, ensuring precise control over the brewing process according to the specified profile.

## 7. Future Extensions

The evolution of the Open Espresso Profile Format (OEPF) aims to introduce greater flexibility and programmability to the coffee brewing process. Two significant enhancements are on the horizon:

1) **Integration of the BEANS Domain Specific Language**: The incorporation of the BEANS Domain Specific Language (DSL), accessible at [BEANS Interpreter GitHub](https://github.com/tyalie/BEANS-interpreter), is poised to revolutionize the execution logic of brewing profiles. By enabling fully Turing-complete logic within the profiles, users will gain unprecedented control over the brewing process, allowing for complex decision-making, loops, and conditional operations tailored to the specificities of each individual shot.

2) **Enhanced Exit Triggers with 'target' Field**: The proposal to enrich exit triggers with a "target" field introduces a dynamic flow control mechanism within the brewing profiles. Upon the activation of an exit trigger, the "target" field will specify the key of the next stage to execute, facilitating non-linear progression through the brewing stages. This enhancement allows for adaptive brewing sequences that can adjust in real-time to the coffee's extraction characteristics or external inputs.

