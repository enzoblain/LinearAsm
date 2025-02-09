# **LinearASM**

Welcome to **LinearASM**! 🎉 This project brings the power of **Linear Regression** into the world of **Assembly Language**. It’s an exciting journey where we dive deep into low-level programming while solving a classic machine learning problem: predicting the relationship between variables.

Whether you're a beginner or an experienced coder, this project will give you hands-on experience with **Assembly** and help you understand how math algorithms like linear regression can be executed at the hardware level. Get ready to write some **real raw code**! 💻

## **What’s This Project About?**

In **LinearASM**, we’re implementing the heart of **Linear Regression** in **Assembly Language**. Instead of relying on high-level libraries like `numpy` or `scikit-learn`, we’re rolling up our sleeves and doing the math by hand—using the basic operations like addition, subtraction, multiplication, and division—all in **Assembly**! 🚀

You’ll not only learn the math behind linear regression but also get a solid understanding of how to manage memory and registers at a low level. This project is **your first step** into the world of low-level programming and **machine learning** at the assembly level.

## **Key Features**
- 🔥 **Linear Regression** written entirely in **Assembly**.
- ✨ **Pure assembly calculations** for slope and intercept of the regression line.
- 🧠 A deep dive into how assembly can perform machine learning tasks.
- 🛠️ No high-level libraries here, just pure raw power and memory management.
- 📈 A step-by-step approach to implementing a math algorithm at the lowest possible level.

## **Installation & Setup** 🛠️

Ready to start coding? Just follow these easy steps:

### 1. **Clone the Repo**

First, clone the project to your local machine and head into the project directory:

```sh
git clone https://github.com/yourusername/LinearASM.git
cd LinearASM
```

### 2. **Make the `build.sh` Script Executable** 🛠️

Before running the **`build.sh`** script, you'll need to give it the right permissions to make it executable. To do that, run the following command:

```sh
chmod +x build.sh
```

**What’s happening here:**

- The **`chmod`** command stands for **change mode**, and the **`+x`** flag adds **execute** permissions to the **`build.sh`** script.
- Without this permission, macOS won’t allow you to run the script directly. By adding the **execute permission**, you’re telling the system that you want the script to be run as a program.

### 3. **Build the Project** 🚀

Once everything’s set up, **no worries about complex build steps**—you don’t need to manually run the `as` and `ld` commands. Just run the **`build.sh`** script and let it handle the heavy lifting!



```sh
./build.sh
```

This script will:
- Assemble your source code (convert `.s` to object files).
- Link it into a runnable executable.
- Run the program

This will execute the **Linear Regression** algorithm, calculating the slope (`m`) and intercept (`b`) of the regression line.

---

## **How Does It Work?** 🧮

In this project, **Linear Regression** uses the least squares method to calculate the best-fitting line through data points. The formulae we implement in **Assembly** are:

- **Slope (m)**:  
$$ 
    m = \frac{\sum (x_i - \text{mean}(x)) \cdot (y_i - \text{mean}(y))}{\sum (x_i - \text{mean}(x))^2} 
$$

- **Intercept (b)**:  
$$
    b = \text{mean}(y) - m \cdot \text{mean}(x)
$$

These formulas are converted to low-level assembly instructions, and your **CPU** does all the math directly. No fancy optimizations, just basic **ADD**, **MUL**, and **DIV** instructions handling the operations.

---

## **Project Structure** 📂

Here’s what you’ll find in the project:

- **`main.s`**: The heart of the project! This file contains the linear regression algorithm implemented entirely in **Assembly**.
- **`README.md`**: You’re reading it! This guide explains how to set up, run, and understand the project.
- **`build.sh`**: The magic script that handles building and compiling the assembly source into a runnable program.
- **`LICENSE`**: The license for the project (MIT License).

---

## **Contributing** 💡

Got a cool idea or want to help improve **LinearASM**? I’m all ears! Here’s how you can contribute:

1. **Fork** the repository.
2. Create a new branch: `git checkout -b feature/your-feature`.
3. Make your changes and test them.
4. Commit your changes: `git commit -am 'Add new feature'`.
5. **Push** to your branch: `git push origin feature/your-feature`.
6. Open a **pull request**!

I welcome **ideas, improvements**, and even just friendly **feedback**!

---

## **License** 📜

This project is open-source and licensed under the [MIT License](LICENSE).

---

## **Why Assembly?** 🤔

You might wonder: *Why go through the trouble of implementing Linear Regression in Assembly?*

I decided to learn Assembly because I’m comfortable with high-level languages like Python and PHP, but I wanted to understand how machines really work at their core. The answer is simple: **It’s a deep dive into the magic of computers**. Assembly is the language closest to the machine—giving you direct access to how the hardware processes and executes instructions. By implementing something as familiar as **Linear Regression** in Assembly, you’ll learn not only how algorithms are implemented at a low level but also how the machine handles operations and manages resources under the hood.

**LinearASM** is your **exploration** into how low-level programming can power even the simplest machine learning algorithms. Ready to take the plunge into the world of Assembly? Let’s go! 🚀

---

### **Final Words** ✨

If you ever get stuck or need help understanding how something works in the code, don’t hesitate to open an issue or drop a question! This is all about learning and having fun with low-level programming. 👨‍💻👩‍💻

Good luck, and enjoy hacking away at **LinearASM**! 😄
