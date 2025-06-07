#ifndef MMAP_GPIO_HPP
#define MMAP_GPIO_HPP

#include <fcntl.h>
#include <sys/mman.h>
#include <unistd.h>
#include <cstdint>
#include <stdexcept>
#include <QDebug>

class MmapGpio {
public:
    MmapGpio() {
        int mem_fd = open("/dev/gpiomem", O_RDWR | O_SYNC);
        if (mem_fd < 0) {
            throw std::runtime_error("Failed to open /dev/gpiomem. Run as root or add user to gpio group.");
        }

        m_gpio_map = mmap(
            NULL,
            4096,
            PROT_READ | PROT_WRITE,
            MAP_SHARED,
            mem_fd,
            0
            );

        close(mem_fd);

        if (m_gpio_map == MAP_FAILED) {
            throw std::runtime_error("mmap failed.");
        }

        m_gpio_base = static_cast<volatile uint32_t*>(m_gpio_map);
    }

    ~MmapGpio() {
        if (m_gpio_map != MAP_FAILED) {
            munmap(const_cast<void*>(m_gpio_map), 4096);
        }
    }

    void setAsOutput(int pin) {
        if (pin < 0 || pin > 27) return;
        int regIndex = pin / 10;
        int shift = (pin % 10) * 3;
        m_gpio_base[regIndex] &= ~(7 << shift);
        m_gpio_base[regIndex] |= (1 << shift);
    }

    void setAsInput(int pin) {
        if (pin < 0 || pin > 27) return;
        int regIndex = pin / 10;
        int shift = (pin % 10) * 3;
        m_gpio_base[regIndex] &= ~(7 << shift);
    }

    void write(int pin, bool value) {
        if (pin < 0 || pin > 27) return;
        int regIndex = value ? 7 : 10;
        m_gpio_base[regIndex] = 1 << pin;
    }

    bool read(int pin) {
        if (pin < 0 || pin > 27) return false;
        return (m_gpio_base[13] & (1 << pin)) != 0;
    }

private:
    volatile void* m_gpio_map = MAP_FAILED;
    volatile uint32_t* m_gpio_base = nullptr;
};

#endif // MMAP_GPIO_HPP
