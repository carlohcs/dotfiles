# Setup & Node.js Isolation for Alfred Workflows (asdf)

A guide for installing and configuring workflows built on the **Alfy** ecosystem (e.g., `alfred-fkill`) in environments using **asdf** as the Node.js version manager.

---

## 1. The Problem

Workflows built on top of Alfy internally use a utility called `run-node` (`./node_modules/.bin/run-node index.js "$1"`), which attempts to resolve the Node binary by spawning a login subshell and caching the path at `~/.node_path`.

When you use `asdf` and frequently switch Node versions across projects:

- Alfred does not load your `.zshrc`/`.bashrc` by default (meaning it cannot see the shims in `~/.asdf/shims`).
- Global version switches or deleting older Node versions in `asdf` will break the workflow.
- The `run-node` cache can get stuck pointing to an incompatible or missing version.

---

## 2. Installation & Hardening Steps

To permanently stabilize the workflow, lock its execution directly to a dedicated LTS Node binary installed via `asdf`.

### Step 1: Install using a dedicated LTS version

1. In your terminal, temporarily switch to the LTS Node version you want to dedicate to global tools:

   ```bash
   asdf shell nodejs <your-lts-version>
   ```

   *(Example: `asdf shell nodejs 22.11.0` or `20.18.0`)*

2. Install the workflow globally:

   ```bash
   npm install --global alfred-fkill
   ```

   *(Alfy will create the appropriate symlink inside Alfred's workflows directory).*

---

### Step 2: Set the absolute Node path inside Alfred

1. Open **Alfred Preferences** (`Cmd + ,`) > **Workflows** tab > select **fkill**.
2. Locate the initial trigger block (**Script Filter** - magnifying glass icon) and double-click it.
   - The default command is:

     ```bash
     ./node_modules/.bin/run-node index.js "$1"
     ```

   - Replace it with:

     ```bash
     "$HOME/.asdf/installs/nodejs/<your-lts-version>/bin/node" index.js "$1"
     ```

     *(Replace `<your-lts-version>` with the exact directory name, e.g., `22.11.0`)*.
3. Locate the subsequent action block (**Run Script** - triggered on pressing Enter).
   - If it calls `run-node`, replace it with the same absolute path:

     ```bash
     "$HOME/.asdf/installs/nodejs/<your-lts-version>/bin/node" ...
     ```

4. Save the changes by clicking **Save**.

---

## 3. About the npm Warning (`allowScripts` / `alfy-init`)

During global installation, you might see a warning like this:

```text
npm warn install-scripts 1 package has install scripts not yet covered by allowScripts:
npm warn install-scripts   alfred-fkill@0.4.1 (postinstall: alfy-init)
npm warn install-scripts
npm warn install-scripts Run `npm install -g --allow-scripts=alfred-fkill` to allow these scripts once, or `npm config set allow-scripts=alfred-fkill --location=user` to allow them for all global installs.
```

### What does it mean?

- **Security feature:** Recent versions of npm (v11+) notify users whenever an installed package contains lifecycle scripts (`preinstall`, `postinstall`).
- **Default behavior:** For now, this is purely advisory. The `postinstall` script (`alfy-init`) **still executes normally**.
- **Role of `alfy-init`:** This script's sole purpose is creating the symlink inside Alfred's preference directory (`~/Library/Application Support/Alfred/Alfred.alfredpreferences/workflows/...`).
- **Action required:** **None**. If the workflow appears in Alfred's preferences list, the script has already completed its job successfully. If a future npm release starts blocking scripts by default, run the install command with the suggested flag:

  ```bash
  npm install -g --allow-scripts=alfred-fkill alfred-fkill
  ```

---

## 4. Key Benefits

- **Immune to `.tool-versions`:** Changing Node versions in project directories will never impact Alfred.
- **Instant Response:** No overhead from shim resolution or subshell spawns.
- **Predictability:** The workflow always executes in the exact environment where its dependencies were compiled.
