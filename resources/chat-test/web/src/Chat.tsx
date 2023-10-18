import { AnimatePresence, motion } from "framer-motion";
import { useEffect, useState } from "react";
import "./Chat.css";

export default function Chat() {
    const [messages, setMessages] = useState([
        {
            author: "system",
            content: "Welcome to the chat!",
        },
        {
            author: "system",
            content: "This is a test message.",
        },
    ]);
    const [input, setInput] = useState("");

    useEffect(() => {
        const handleMessage = (event) => {
            const data = event.data;
            console.log(data);
        };

        document.addEventListener("message", handleMessage);
        return () => document.removeEventListener("message", handleMessage);
    }, []);

    function sendMessage(message) {}

    return (
        <AnimatePresence>
            <motion.div className="container">
                <div className="messages">
                    {messages.map((message, index) => (
                        <div key={index}>
                            <span>{message.author}</span>
                            <span>{message.content}</span>
                        </div>
                    ))}
                </div>

                <div className="input">
                    <input
                        type="text"
                        value={input}
                        onChange={(e) => setInput(e.target.value)}
                        onKeyDown={(e) => {
                            if (e.key === "Enter") {
                                sendMessage(input);
                            }
                        }}
                    />

                    <button>s</button>
                </div>
            </motion.div>
        </AnimatePresence>
    );
}
