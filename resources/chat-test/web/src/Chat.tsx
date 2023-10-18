import { AnimatePresence, motion } from "framer-motion";
import { useEffect, useState } from "react";
import "./Chat.css";

export default function Chat() {
    // @ts-expect-error
    const [messages, setMessages] = useState([
        {
            author: "system",
            content: "Welcome to the chat!",
            createdAt: new Date(),
        },
        {
            author: "system",
            content: "This is a test message.",
            createdAt: new Date(),
        },
    ]);
    const [input, setInput] = useState("");

    useEffect(() => {
        const handleMessage = (event: any) => {
            const data = event.data;
            console.log(JSON.stringify(data, null, 4));
        };

        window.addEventListener("message", handleMessage);
        return () => window.removeEventListener("message", handleMessage);
    }, []);

    function sendMessage(message: string) {
        console.log("sending message", message);
        setInput("");
    }

    return (
        <AnimatePresence>
            <motion.div
                className="container"
                initial={{ opacity: 0.5, scale: 0.6 }}
                animate={{ opacity: 1, scale: 1 }}
                exit={{ opacity: 0.5, scale: 0.6 }}
                transition={{ duration: 0.2, ease: "easeInOut" }}
            >
                <div className="messages">
                    {messages.map((message, index) => (
                        <div key={index}>
                            <h3>
                                <span>{message.author}</span>
                                <span>
                                    {message.createdAt.toLocaleTimeString("en-US", {
                                        hour: "numeric",
                                        minute: "numeric",
                                    })}
                                </span>
                            </h3>

                            <span>{message.content}</span>
                        </div>
                    ))}
                </div>

                <div className="input">
                    <input
                        autoFocus
                        type="text"
                        value={input}
                        placeholder="Type a message"
                        onChange={(e) => setInput(e.target.value)}
                        onKeyDown={(e) => {
                            if (e.key === "Enter") {
                                sendMessage(input);
                            }
                        }}
                    />

                    <button onClick={() => sendMessage(input)}>
                        <svg
                            xmlns="http://www.w3.org/2000/svg"
                            width="22"
                            height="22"
                            viewBox="0 0 24 24"
                            stroke-width="2"
                            stroke="currentColor"
                            fill="none"
                            stroke-linecap="round"
                            stroke-linejoin="round"
                        >
                            <path stroke="none" d="M0 0h24v24H0z" fill="none" />
                            <path d="M10 14l11 -11" />
                            <path d="M21 3l-6.5 18a.55 .55 0 0 1 -1 0l-3.5 -7l-7 -3.5a.55 .55 0 0 1 0 -1l18 -6.5" />
                        </svg>
                    </button>
                </div>
            </motion.div>
        </AnimatePresence>
    );
}
